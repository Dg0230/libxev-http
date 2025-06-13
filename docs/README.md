# libxev-http GitHub Pages

This directory contains the GitHub Pages website for libxev-http.

## 🚀 Quick Setup

### 1. Enable GitHub Pages

1. Go to your repository settings on GitHub
2. Scroll down to "Pages" section
3. Under "Source", select "Deploy from a branch"
4. Choose "main" branch and "/docs" folder
5. Click "Save"

### 2. Update Configuration

Edit `docs/_config.yml` and update the following:

```yaml
url: "https://dg0230.github.io"
baseurl: "/libxev-http"  # or your repository name
repository: "dg0230/libxev-http"
```

### 3. Update Links

Update all GitHub links in the HTML files:
- `docs/index.html`
- `docs/api.html`
- `docs/examples.html`

Replace `dg0230` with your actual GitHub username.

## 📁 File Structure

```
docs/
├── index.html          # Main homepage
├── api.html           # API documentation
├── examples.html      # Code examples
├── style.css          # Styles
├── script.js          # JavaScript functionality
├── _config.yml        # Jekyll configuration
└── README.md          # This file
```

## 🎨 Customization

### Colors and Branding

Edit `docs/style.css` to customize:

```css
:root {
    --primary-color: #f7931e;     /* Orange accent */
    --secondary-color: #2563eb;   /* Blue */
    --accent-color: #10b981;      /* Green */
    /* ... other colors */
}
```

### Content Updates

- **Homepage**: Edit `docs/index.html`
- **API Docs**: Edit `docs/api.html`
- **Examples**: Edit `docs/examples.html`

### Adding New Pages

1. Create new HTML file in `docs/`
2. Add navigation link to all pages
3. Update `_config.yml` if needed

## 🔧 Features

### Responsive Design
- Mobile-friendly navigation
- Responsive grid layouts
- Touch-friendly interactions

### Interactive Elements
- Copy-to-clipboard for code examples
- Smooth scrolling navigation
- Animated elements on scroll

### SEO Optimized
- Meta tags for social sharing
- Structured data
- Sitemap generation

### Performance
- Optimized CSS and JavaScript
- Compressed assets
- Fast loading times

## 🌐 Custom Domain (Optional)

To use a custom domain:

1. Create `docs/CNAME` file with your domain:
   ```
   libxev-http.yourdomain.com
   ```

2. Configure DNS records:
   ```
   CNAME libxev-http.yourdomain.com dg0230.github.io
   ```

3. Update `_config.yml`:
   ```yaml
   url: "https://libxev-http.yourdomain.com"
   baseurl: ""
   ```

## 📊 Analytics (Optional)

Add Google Analytics by updating `_config.yml`:

```yaml
google_analytics: UA-XXXXXXXX-X
```

## 🔒 Security Headers

The site includes security headers:
- X-Frame-Options: DENY
- X-Content-Type-Options: nosniff
- X-XSS-Protection: 1; mode=block
- Referrer-Policy: strict-origin-when-cross-origin

## 🚀 Deployment

The site will automatically deploy when you:
1. Push changes to the main branch
2. GitHub Actions will build and deploy the site
3. Changes will be live within a few minutes

## 📝 Content Guidelines

### Code Examples
- Use proper Zig syntax highlighting
- Include copy buttons for code blocks
- Provide complete, runnable examples
- Add explanatory comments

### Documentation
- Keep API docs up to date with code changes
- Use consistent formatting
- Include parameter types and descriptions
- Provide usage examples

### Design
- Maintain consistent color scheme
- Use readable fonts and sizes
- Ensure accessibility compliance
- Test on multiple devices

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

## 📚 Resources

- [GitHub Pages Documentation](https://docs.github.com/en/pages)
- [Jekyll Documentation](https://jekyllrb.com/docs/)
- [Markdown Guide](https://www.markdownguide.org/)

## 🤝 Contributing

To contribute to the website:

1. Fork the repository
2. Make changes in the `docs/` directory
3. Test locally if possible
4. Submit a pull request

## 📄 License

This website is part of the libxev-http project and is licensed under the MIT License.
