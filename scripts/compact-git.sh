#!/usr/bin/bash
#!/usr/bin/zsh
#!/usr/bin/sh

# Compact the current Git repository by expiring reflog and running garbage collection.
# This is useful for reducing the size of the Git repository and cleaning up unnecessary objects.
# This script is safe to run in every Git repository, as it only performs maintenance tasks.

echo "==== Compact Git repository ====="
echo ">>> Current Git repository size:"
git count-objects -vH
echo ">>> Expiring reflog and running garbage collection..."
git reflog expire --expire=now --all
git gc --prune=now
echo ">>> Git repository compacted."
echo ">>> Current Git repository size after compaction:"
git count-objects -vH
echo ">>> Hint: You can further compact by running 'git gc --aggressive' (very slow but thorough, may take a very long time)"