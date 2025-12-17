# n8n 2.0.3 Upgrade Notes

## Version Update
- **From**: n8n 1.123.5
- **To**: n8n 2.0.3
- **Date**: 2025-12-17

## Changes in this Release

### Bug Fixes
- Error running evaluations in queue mode
- Git node now only supports specified git config keys

### Deployment Instructions

1. **Pull the latest changes**:
   ```bash
   git pull origin main
   ```

2. **Rebuild and restart the n8n container**:
   ```bash
   docker-compose down
   docker-compose pull
   docker-compose up -d
   ```

3. **Verify the upgrade**:
   ```bash
   docker-compose ps
   docker-compose logs n8n
   ```

## Testing Recommendations

- Test existing workflows to ensure compatibility
- Verify queue mode operations are functioning correctly
- Check Git node configurations if applicable

## Support

For detailed release notes, visit:
https://github.com/n8n-io/n8n/releases/tag/n8n%402.0.3

## Rollback (if needed)

If you need to rollback to the previous version:
```bash
git revert <commit-hash>
docker-compose down
docker-compose pull
docker-compose up -d
```
