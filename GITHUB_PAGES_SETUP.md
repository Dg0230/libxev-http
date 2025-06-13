# GitHub Pages Setup Guide

This guide will help you set up GitHub Pages for the libxev-http project.

## 🚀 Quick Deployment Steps

### 1. Enable GitHub Pages

1. Go to your GitHub repository
2. Click the **Settings** tab
3. Find **Pages** in the left sidebar
4. Under **Build and deployment**:
   - **Source**: Select "Deploy from a branch"
   - **Branch**: Choose **main** branch and **/docs** folder
   - Click **Save**

**Note**: GitHub Pages now uses GitHub Actions to execute Jekyll builds. Make sure GitHub Actions is enabled in your repository.

### 2. Update Configuration

Edit the `docs/_config.yml` file and update the following:

```yaml
url: "https://YOUR-USERNAME.github.io"
baseurl: "/libxev-http"  # or your repository name
repository: "YOUR-USERNAME/libxev-http"
```

Replace `YOUR-USERNAME` with your actual GitHub username.

### 3. Update HTML Links

Replace all instances of `your-username` with your actual GitHub username in:

- `docs/index.html`
- `docs/api.html`
- `docs/examples.html`

Search and replace:
```html
<!-- Before -->
<a href="https://github.com/your-username/libxev-http">

<!-- After -->
<a href="https://github.com/YOUR-USERNAME/libxev-http">
```

### 4. Update robots.txt

Edit `docs/robots.txt`:

```
User-agent: *
Allow: /

Sitemap: https://YOUR-USERNAME.github.io/libxev-http/sitemap.xml
```

## 🔧 Custom Configuration

### Custom Domain (Optional)

If you have a custom domain:

1. Create `docs/CNAME` file:
   ```
   libxev-http.yourdomain.com
   ```

2. Configure DNS records:
   ```
   CNAME libxev-http.yourdomain.com YOUR-USERNAME.github.io
   ```

3. Update `_config.yml`:
   ```yaml
   url: "https://libxev-http.yourdomain.com"
   baseurl: ""
   ```

### Custom Styling

Edit `docs/style.css` to customize colors and styles:

```css
:root {
    --primary-color: #f7931e;     /* Primary color */
    --secondary-color: #2563eb;   /* Secondary color */
    --accent-color: #10b981;      /* Accent color */
}
```

### Add Google Analytics (Optional)

Add to `docs/_config.yml`:

```yaml
google_analytics: UA-XXXXXXXX-X
```

## 📁 File Structure

```
docs/
├── index.html          # Homepage
├── api.html           # API documentation
├── examples.html      # Code examples
├── style.css          # Stylesheet
├── script.js          # JavaScript functionality
├── _config.yml        # Jekyll configuration
├── Gemfile            # Ruby dependencies
├── robots.txt         # Search engine configuration
├── manifest.json      # PWA configuration
├── 404.html           # Custom 404 page
├── sitemap.xml        # Site map
└── README.md          # Documentation
```

## 🚀 自动部署

### GitHub Actions Workflow

The project includes a GitHub Actions workflow (`.github/workflows/pages.yml`) that automatically deploys when:

- Pushing to the main branch
- Changes are made to the `docs/` directory
- Manually triggering the workflow

### Deployment Options

**Option 1: Use GitHub Actions (Recommended)**
- Automatic Jekyll build and deployment
- Support for custom plugins and themes
- Better build error reporting

**Option 2: Deploy Static Files Directly**
If you want to bypass Jekyll processing:
1. Rename `docs/.nojekyll.example` to `docs/.nojekyll`
2. Remove or rename `_config.yml` and `Gemfile`
3. GitHub Pages will serve HTML files directly

## 🌐 Access Your Website

After deployment, your website will be available at:

```
https://YOUR-USERNAME.github.io/libxev-http/
```

## 🎨 Website Features

### Responsive Design
- Mobile-friendly navigation
- Responsive grid layouts
- Touch-friendly interactions

### Interactive Features
- Copy-to-clipboard for code examples
- Smooth scrolling navigation
- Animated elements on scroll

### SEO Optimized
- Social sharing meta tags
- Structured data
- Automatic sitemap generation

### Performance Optimized
- Compressed CSS and JavaScript
- Optimized asset loading
- Fast loading times

## 🔍 Local Development

If you want to preview the website locally:

1. Install Ruby and Bundler
2. Navigate to docs directory:
   ```bash
   cd docs
   ```
3. Install dependencies:
   ```bash
   bundle install
   ```
4. Start local server:
   ```bash
   bundle exec jekyll serve
   ```
5. Visit `http://localhost:4000` in your browser

## 🐛 Troubleshooting

### Site Not Loading
- Check GitHub Pages settings
- Verify `_config.yml` syntax
- Check for build errors in Actions tab

### Broken Links
- Update all internal links to use relative paths
- Check external links periodically
- Use proper baseurl configuration

### Styling Issues
- Clear browser cache
- Check CSS syntax
- Verify file paths

## 📚 Useful Resources

- [GitHub Pages Documentation](https://docs.github.com/en/pages)
- [Jekyll Documentation](https://jekyllrb.com/docs/)
- [Markdown Guide](https://www.markdownguide.org/)

## 🤝 Contributing

To contribute to the website:

1. Fork the repository
2. Make changes in the `docs/` directory
3. Test locally if possible
4. Submit a Pull Request

## ✅ Deployment Checklist

- [ ] Enable GitHub Pages
- [ ] Ensure GitHub Actions is enabled
- [ ] Update URL and repository info in `_config.yml`
- [ ] Replace all `your-username` in HTML files
- [ ] Update sitemap URL in `robots.txt`
- [ ] Test all links and functionality
- [ ] Check mobile responsiveness
- [ ] Verify SEO meta tags
- [ ] Test 404 page functionality
- [ ] Check HTTPS is working properly

After completing these steps, your libxev-http project will have a professional GitHub Pages website!
