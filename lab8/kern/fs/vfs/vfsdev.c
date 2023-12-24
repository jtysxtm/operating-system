#include <defs.h>
#include <stdio.h>
#include <string.h>
#include <vfs.h>
#include <dev.h>
#include <inode.h>
#include <sem.h>
#include <list.h>
#include <kmalloc.h>
#include <unistd.h>
#include <error.h>
#include <assert.h>
#include <proc.h>
// device info entry in vdev_list 
typedef struct {
    const char *devname;
    struct inode *devnode;
    struct fs *fs;
    bool mountable;
    list_entry_t vdev_link;
} vfs_dev_t;// 通过链接 vfs_dev_t 结构的双向链表找到 device 对应的 inode 数据结构

#define le2vdev(le, member)                         \
    to_struct((le), vfs_dev_t, member)

// 通过访问此链表，可以找到 ucore 能够访问的所有设备文件
static list_entry_t vdev_list;     // device info list in vfs layer
static semaphore_t vdev_list_sem;  // 互斥访问的semaphore

static void
lock_vdev_list(void) {
    down(&vdev_list_sem);
}// 通过信号量实现对虚拟文件系统设备列表的加锁操作

static void
unlock_vdev_list(void) {
    up(&vdev_list_sem);
}// 通过信号量实现对虚拟文件系统设备列表的解锁操作

void
vfs_devlist_init(void) {
    // 初始化虚拟文件系统设备列表，列表头指向自身，信号量初始值为1
    list_init(&vdev_list);
    sem_init(&vdev_list_sem, 1);
}

// vfs_cleanup - finally clean (or sync) fs
void
vfs_cleanup(void) {
    if (!list_empty(&vdev_list)) {
        lock_vdev_list();
        {
            list_entry_t *list = &vdev_list, *le = list;
            while ((le = list_next(le)) != list) {
                vfs_dev_t *vdev = le2vdev(le, vdev_link);
                if (vdev->fs != NULL) {
                    fsop_cleanup(vdev->fs);
                }
            }
        }
        unlock_vdev_list();
    }
}

/*
 * vfs_get_root - Given a device name (stdin, stdout, etc.), hand
 *                back an appropriate inode.
 */
int
vfs_get_root(const char *devname, struct inode **node_store) {
    assert(devname != NULL);
    int ret = -E_NO_DEV;
    if (!list_empty(&vdev_list)) {
        lock_vdev_list();
        {
            list_entry_t *list = &vdev_list, *le = list;
            while ((le = list_next(le)) != list) {
                vfs_dev_t *vdev = le2vdev(le, vdev_link);
                if (strcmp(devname, vdev->devname) == 0) {
                    struct inode *found = NULL;
                    if (vdev->fs != NULL) {
                        found = fsop_get_root(vdev->fs);
                    }
                    else if (!vdev->mountable) {
                        vop_ref_inc(vdev->devnode);
                        found = vdev->devnode;
                    }
                    if (found != NULL) {
                        ret = 0, *node_store = found;
                    }
                    else {
                        ret = -E_NA_DEV;
                    }
                    break;
                }
            }
        }
        unlock_vdev_list();
    }
    return ret;
}

/*
 * vfs_get_devname - Given a filesystem, hand back the name of the device it's mounted on.
 */
const char *
vfs_get_devname(struct fs *fs) {
    assert(fs != NULL);
    list_entry_t *list = &vdev_list, *le = list;
    while ((le = list_next(le)) != list) {
        vfs_dev_t *vdev = le2vdev(le, vdev_link);
        if (vdev->fs == fs) {
            return vdev->devname;
        }
    }
    return NULL;
}

/*
 * check_devname_confilct - Is there alreadily device which has the same name?
 */
//判断是否已经存在同名的设备
static bool
check_devname_conflict(const char *devname) {
    list_entry_t *list = &vdev_list, *le = list;

    // 遍历虚拟文件系统设备列表，查找是否已存在同名设备
    while ((le = list_next(le)) != list) {
        vfs_dev_t *vdev = le2vdev(le, vdev_link);
        if (strcmp(vdev->devname, devname) == 0) {
            return 0;// 存在同名设备，返回假
        }
    }
    return 1;// 不存在同名设备，返回真
}


/*
* vfs_do_add - Add a new device to the VFS layer's device table.
*
* If "mountable" is set, the device will be treated as one that expects
* to have a filesystem mounted on it, and a raw device will be created
* for direct access.
*/
static int
vfs_do_add(const char *devname, struct inode *devnode, struct fs *fs, bool mountable) {
    // 执行将设备添加到虚拟文件系统中的操作
    assert(devname != NULL);
    assert((devnode == NULL && !mountable) || (devnode != NULL && check_inode_type(devnode, device)));
    // 检查设备名长度是否超过限制
    if (strlen(devname) > FS_MAX_DNAME_LEN) {
        return -E_TOO_BIG;
    }

    int ret = -E_NO_MEM;
    // 复制设备名
    char *s_devname;
    if ((s_devname = strdup(devname)) == NULL) {
        return ret;
    }

    // 分配并初始化虚拟文件系统设备结构
    vfs_dev_t *vdev;
    if ((vdev = kmalloc(sizeof(vfs_dev_t))) == NULL) {
        goto failed_cleanup_name;
    }

    ret = -E_EXISTS;
    // 加锁，防止并发修改虚拟文件系统设备列表
    lock_vdev_list();
    // 检查设备名是否冲突
    if (!check_devname_conflict(s_devname)) {
        unlock_vdev_list();
        goto failed_cleanup_vdev;
    }

    // 初始化虚拟文件系统设备结构
    vdev->devname = s_devname;
    vdev->devnode = devnode;
    vdev->mountable = mountable;
    vdev->fs = fs;

    // 将设备添加到虚拟文件系统设备列表中
    list_add(&vdev_list, &(vdev->vdev_link));
    // 解锁虚拟文件系统设备列表
    unlock_vdev_list();
    return 0;

failed_cleanup_vdev:
    kfree(vdev);
failed_cleanup_name:
    kfree(s_devname);
    return ret;
}

/*
 * vfs_add_fs - Add a new fs,  by name. See  vfs_do_add information for the description of
 *              mountable.
 */
int
vfs_add_fs(const char *devname, struct fs *fs) {
    return vfs_do_add(devname, NULL, fs, 0);
}

/*
 * vfs_add_dev - Add a new device, by name. See  vfs_do_add information for the description of
 *               mountable.
 */
int
vfs_add_dev(const char *devname, struct inode *devnode, bool mountable) {
    // 将设备添加到虚拟文件系统中
    return vfs_do_add(devname, devnode, NULL, mountable);
}

/*
 * find_mount - Look for a mountable device named DEVNAME.
 *              Should already hold vdev_list lock.
 */
// 查找可挂载设备
static int
find_mount(const char *devname, vfs_dev_t **vdev_store) {
    assert(devname != NULL);
    list_entry_t *list = &vdev_list, *le = list;

    // 遍历设备列表，查找匹配的设备
    while ((le = list_next(le)) != list) {
        vfs_dev_t *vdev = le2vdev(le, vdev_link);
        if (vdev->mountable && strcmp(vdev->devname, devname) == 0) {
            *vdev_store = vdev;
            return 0;
        }
    }
    return -E_NO_DEV;// 没有找到匹配的设备
}

/*
 * vfs_mount - Mount a filesystem. Once we've found the device, call MOUNTFUNC to
 *             set up the filesystem and hand back a struct fs.
 *
 * The DATA argument is passed through unchanged to MOUNTFUNC.
 */
// 挂载文件系统
int
vfs_mount(const char *devname, int (*mountfunc)(struct device *dev, struct fs **fs_store)) {
    int ret;
    lock_vdev_list();// 加锁，防止并发挂载操作

    vfs_dev_t *vdev;

    // 查找挂载设备
    if ((ret = find_mount(devname, &vdev)) != 0) {
        goto out;
    }

    // 检查设备是否已经挂载
    if (vdev->fs != NULL) {
        ret = -E_BUSY;
        goto out;
    }

    // 确保挂载设备的名称和属性不为空。
    assert(vdev->devname != NULL && vdev->mountable);

    // 获取设备信息并调用挂载函数
    struct device *dev = vop_info(vdev->devnode, device);// 获取挂载设备的信息结构
    if ((ret = mountfunc(dev, &(vdev->fs))) == 0) {//调用挂载函数，将设备信息和文件系统指针传递给挂载函数
        assert(vdev->fs != NULL);// 确保文件系统指针已被正确设置
        cprintf("vfs: mount %s.\n", vdev->devname);// 打印挂载成功信息
    }

out:
    unlock_vdev_list();// 解锁全局设备列表，允许其他线程进行挂载操作
    return ret;
}

/*
 * vfs_unmount - Unmount a filesystem/device by name.
 *               First calls FSOP_SYNC on the filesystem; then calls FSOP_UNMOUNT.
 */
int
vfs_unmount(const char *devname) {
    int ret;
    lock_vdev_list();
    vfs_dev_t *vdev;
    if ((ret = find_mount(devname, &vdev)) != 0) {
        goto out;
    }
    if (vdev->fs == NULL) {
        ret = -E_INVAL;
        goto out;
    }
    assert(vdev->devname != NULL && vdev->mountable);

    if ((ret = fsop_sync(vdev->fs)) != 0) {
        goto out;
    }
    if ((ret = fsop_unmount(vdev->fs)) == 0) {
        vdev->fs = NULL;
        cprintf("vfs: unmount %s.\n", vdev->devname);
    }

out:
    unlock_vdev_list();
    return ret;
}

/*
 * vfs_unmount_all - Global unmount function.
 */
int
vfs_unmount_all(void) {
    if (!list_empty(&vdev_list)) {
        lock_vdev_list();
        {
            list_entry_t *list = &vdev_list, *le = list;
            while ((le = list_next(le)) != list) {
                vfs_dev_t *vdev = le2vdev(le, vdev_link);
                if (vdev->mountable && vdev->fs != NULL) {
                    int ret;
                    if ((ret = fsop_sync(vdev->fs)) != 0) {
                        cprintf("vfs: warning: sync failed for %s: %e.\n", vdev->devname, ret);
                        continue ;
                    }
                    if ((ret = fsop_unmount(vdev->fs)) != 0) {
                        cprintf("vfs: warning: unmount failed for %s: %e.\n", vdev->devname, ret);
                        continue ;
                    }
                    vdev->fs = NULL;
                    cprintf("vfs: unmount %s.\n", vdev->devname);
                }
            }
        }
        unlock_vdev_list();
    }
    return 0;
}

