@echo off
git submodule update --checkout -f
git apply %~dp0..\patches\tmetafile_polyfill.diff
