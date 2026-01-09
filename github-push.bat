@echo off
chcp 65001 >nul
title GitHub推送脚本

:push_attempt
cls
echo 正在推送代码到GitHub仓库...
echo.

git remote rm origin
git remote add origin https://github.com/wuyuanwuhui999/flutter-music-app-ui
git push origin main

if %errorlevel% equ 0 (
    echo.
    echo ✓ 推送成功！
    echo 窗口将在5秒后自动关闭...
    timeout /t 5 /nobreak >nul
    exit
) else (
    echo.
    echo ✗ 推送失败，错误代码: %errorlevel%
    echo.
    echo 按回车键重试推送，或按 Ctrl+C 退出...
    pause >nul
    goto push_attempt
)