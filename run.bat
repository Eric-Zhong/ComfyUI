@REM @echo off
@REM chcp 65001

@REM rem 检查 models 是否存在并判断是否为软连接
@REM set link_dir=models
@REM dir /al %link_dir%* | find "SYMLINK" > nul
@REM rem echo 出错信息：%errorlevel%
@REM if %errorlevel% equ 0 (
@REM     echo %link_dir% 已存在软连接，跳过创建软连接
@REM ) else (
@REM     rmdir /s /q %link_dir%
@REM     mklink /d %link_dir% Z:\Service\ComfyUI\custom_nodes
@REM     echo %link_dir% 成功创建软连接
@REM )

@REM rem 检查 custom_nodes 是否存在并判断是否为软连接
@REM set link_dir=custom_nodes
@REM dir /al %link_dir%* | find "SYMLINK" > nul
@REM rem echo 出错信息：%errorlevel%
@REM if %errorlevel% equ 0 (
@REM     echo %link_dir% 已存在软连接，跳过创建软连接
@REM ) else (
@REM     rmdir /s /q %link_dir%
@REM     mklink /d %link_dir% Z:\Service\ComfyUI\custom_nodes
@REM     echo %link_dir% 成功创建软连接
@REM )

@REM rem 激活 conda

conda activate comfyui
python main.py