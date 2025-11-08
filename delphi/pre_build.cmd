@echo off
git submodule update --checkout -f
git apply %~dp0..\patches\suppress_H2443.diff
git apply %~dp0..\patches\catch_memleak.diff
