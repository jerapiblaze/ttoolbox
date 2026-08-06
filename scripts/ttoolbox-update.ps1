# update ttoolbox

Set-Location C:\ttoolbox;
git fetch origin;
if ($?) { git reset --hard origin/main; }