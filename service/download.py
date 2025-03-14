import os
from tqdm import tqdm
import yaml
from pathlib import Path
from types import SimpleNamespace
from git import RemoteProgress, Repo
import wget as wget
import shutil

def dict_to_obj(d):
    return SimpleNamespace(
        **{k: dict_to_obj(v) if isinstance(v, dict) else v for k, v in d.items()}
    )


class CloneProgress(RemoteProgress):
    def __init__(self):
        super().__init__()
        self.pbar = None
        self._last_count = 0

    def update(self, op_code, cur_count, max_count=None, message=""):
        if op_code & self.BEGIN:
            self.pbar = tqdm(
                total=max_count, unit="B", unit_scale=True, desc="克隆进度"
            )
        elif op_code & self.END:
            self.pbar.close()
            self.pbar = None

        if self.pbar:
            increment = cur_count - self._last_count
            self.pbar.update(increment)
            self._last_count = cur_count
            if message:
                self.pbar.set_postfix_str(message)

class TqdmBar(tqdm):
    def __init__(self, *args, **kwargs):
        kwargs.setdefault('unit', 'B')
        kwargs.setdefault('unit_scale', True)
        kwargs.setdefault('unit_divisor', 1024)
        super().__init__(*args, **kwargs)
        
    def update_to(self, current=1, total=1):
        self.total = total
        self.update(current - self.n)

def git_clone(repo_url, local_path):
    """
    克隆 Git 仓库。

    Args:
        repo_url: 远程仓库的 URL。
        local_path: 本地克隆路径。
    """
    try:
        # 规范化路径处理
        local_path = Path(str(local_path).replace("/", os.sep))  # 统一分隔符
        if Path.exists(local_path):
            print(f"已经存在 {local_path}")
        else:
            # 新增目录创建逻辑
            parent_dir = local_path.parent
            parent_dir.mkdir(parents=True, exist_ok=True)  # 创建父目录

            Repo.clone_from(
                repo_url,
                local_path,
                progress=CloneProgress(),
            )
            print(f"已成功克隆到 '{local_path}'")
    except Exception as e:
        print(f"克隆仓库时发生错误：{e}")
        # 新增错误处理：删除已创建的目录
        if Path(local_path).exists():
            shutil.rmtree(local_path, ignore_errors=True)
            print(f"已清理残留目录: {local_path}")

def wget_download(url, save_as, file_name):
    # 规范化路径处理
    local_path = Path(str(save_as).replace("/", os.sep))  # 统一分隔符
    if Path.exists(local_path):
        print(f"已经存在 {local_path}")
    else:
        # 新增目录创建逻辑
        parent_dir = local_path.parent
        parent_dir.mkdir(parents=True, exist_ok=True)  # 创建父目录
        
    save_path = os.path.join(save_as, file_name)
    save_path = Path(save_path)
    
    if save_path.exists():
        print(f"文件 {save_path} 已经存在，跳过下载。")
        return save_path
    else:
        # 下载文件
        # 创建进度条实例
        progress_bar = TqdmBar(desc="下载进度", total=0)    
        # 使用wget下载并绑定进度回调
        file_name = wget.download(
            url,
            out=str(save_path),
            bar=lambda current, total, width: progress_bar.update_to(current, total)
        )        
        progress_bar.close()
        # print(f"\n文件已下载到 {save_path}")

        return save_path

def print_properties(obj, tab=0):
    tab_length = tab
    for attr_name in dir(obj):
        if not attr_name.startswith("__"):  # 过滤魔术方法
            attr_value = getattr(obj, attr_name)
            if attr_value.__class__ is SimpleNamespace:
                print(" " * tab_length * 4, f"{attr_name}")
                print_properties(attr_value, tab_length + 1)
            else:
                if not callable(attr_value):  # 过滤方法
                    print(" " * tab_length * 4, f"{attr_name}: {attr_value}")

def download_models(cfg):
    print("#" * 80)
    print("开始下载同步模型")
    print("#" * 80)
    # 下载方式的配置
    enable_modelscope = cfg.channels.modelscope == True
    enable_huggingface = cfg.channels.huggingface == True
    enable_civitai = cfg.channels.civitai == True

    models = cfg.models

    for attr_name in dir(models):
        if not attr_name.startswith("__"):
            # print(attr_name)
            model = getattr(models, attr_name)
            print(
                # "-" * 20,
                model.name,
                # "-" * 20,
            )
            if enable_modelscope:
                if model.channels != None and model.channels.modelscope != None:
                    _modelscope = model.channels.modelscope
                    if _modelscope.method == "git":
                        save_as = os.path.join(cfg.base.root, model.save_as)
                        # 通过 git 下载模型
                        git_clone(_modelscope.url, save_as)
                    if _modelscope.method == "wget":
                        save_as = os.path.join(cfg.base.root, model.save_as)
                        # 通过 wget 下载模型
                        wget_download(_modelscope.url, save_as, _modelscope.file_name)
            # print(model.channels.modelscope)
            # print(model.save_as)
        pass

def download_custom_nodes(cfg):
    print("#" * 80)
    print("开始下载同步 custom_nodes")
    print("#" * 80)
    # 下载方式的配置

    custom_nodes = cfg.custom_nodes

    for attr_name in dir(custom_nodes):
        if not attr_name.startswith("__"):
            # print(attr_name)
            plugin = getattr(custom_nodes, attr_name)
            print(
                "-" * 20,
                plugin.name,
                "-" * 20,
            )
            if plugin.method == "git":
                save_as = os.path.join(cfg.base.root, 'custom_nodes', plugin.save_as)
                # 通过 git 下载模型
                git_clone(plugin.url, save_as)
        pass



def main():

    # current_dir = os.path.dirname(os.path.abspath(__file__))
    current_dir = Path(__file__).resolve().parent
    config_file_path = os.path.join(current_dir, "model.yaml")

    with open(config_file_path, "r", encoding="utf-8") as f:
        config = yaml.safe_load(f)
        cfg = dict_to_obj(config)
        # 打印yaml配置文件
        print_properties(cfg)
        # 下载 custom_nodes
        download_custom_nodes(cfg)
        # 下载 models
        download_models(cfg)


if __name__ == "__main__":
    main()
