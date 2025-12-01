# Fixing GitHub Pages 404 Error

If you're getting a 404 error, follow these steps:

## Step 1: Enable GitHub Pages

1. Go to your repository: https://github.com/stevsmit/aerovine
2. Click **Settings** → **Pages**
3. Under **Source**, select:
   - **Deploy from a branch**
   - Branch: `gh-pages`
   - Folder: `/ (root)`
4. Click **Save**

## Step 2: Trigger the Workflow

The updated workflow will automatically deploy when you push. To trigger it manually:

1. Go to **Actions** tab in your repository
2. Click **Deploy MkDocs Documentation**
3. Click **Run workflow** → **Run workflow**

## Step 3: Wait for Deployment

- The workflow will take 1-2 minutes to complete
- Once done, your site will be at: `https://stevsmit.github.io/aerovine/`
- It may take a few more minutes for DNS to propagate

## Alternative: Manual Deployment

If the workflow doesn't work, you can deploy manually:

```bash
cd /Users/joealdinger/aerovine-repo
pip install -r requirements.txt
mkdocs gh-deploy --force
```

Then enable GitHub Pages to use the `gh-pages` branch.

## Troubleshooting

### Still getting 404?

1. **Check Actions tab:** Make sure the workflow completed successfully
2. **Check Pages settings:** Verify it's set to `gh-pages` branch
3. **Wait a few minutes:** GitHub Pages can take 5-10 minutes to update
4. **Clear browser cache:** Try incognito/private browsing mode
5. **Check the URL:** Make sure you're using: `https://stevsmit.github.io/aerovine/`

### Workflow failing?

- Check the Actions tab for error messages
- Make sure `requirements.txt` is in the repository
- Verify `mkdocs.yml` has no syntax errors

