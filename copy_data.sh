rsync -az \
  --include='*/' \
  --include='control.log.INFO.*' \
  --exclude='*' \
  user@remote:/data/record/ ./record/
