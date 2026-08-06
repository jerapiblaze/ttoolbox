# update ttoolbox

Set-Location C:\ttoolbox;
git fetch --depth=1 origin;
if ($?) { git reset --hard origin/main; }