# Jekyll Garden

A beautiful, responsive Jekyll theme for creating a digital garden inspired by Maggie Appleton's design. This theme supports bidirectional links (wikilinks), tagging, dark mode, and includes a graph visualization of your notes.

![Jekyll Garden Screenshot](screenshot.png)

## Features

- 🔄 **Bidirectional Links**: Connect your notes with `[[wikilinks]]`
- 🏷️ **Tagging System**: Organize notes with tags
- 🔍 **Search Functionality**: Full-text search across all notes
- 📊 **Graph View**: Visualize connections between notes
- 🌓 **Dark Mode**: Toggle between light and dark themes
- 📱 **Responsive Design**: Works on mobile and desktop
- 📚 **Book Notes**: Special collection for book notes and reviews
- 📝 **Note Types**: Support for different note types (evergreen, seedling, budding)
- 📰 **RSS Feed**: Automatically generated RSS feed for your notes

## Getting Started

### Prerequisites

- Ruby version 3.0.0 or higher (recommended)
- RubyGems 3.3.22 or higher
- GCC and Make

### Installation

1. **Clone this repository**

```bash
git clone https://github.com/yourusername/jekyll-garden.git
cd jekyll-garden
```

2. **Install dependencies**

```bash
bundle install
```

3. **Start the local server**

```bash
bundle exec jekyll serve
```

4. **Visit your site at** [http://localhost:4000](http://localhost:4000)

## Creating Content

### Notes

Create new notes in the `_notes` directory with the following front matter:

```markdown
---
title: Your Note Title
type: evergreen  # or seedling, budding
tags: [tag1, tag2]
date: YYYY-MM-DD
last_modified_at: YYYY-MM-DD
---

Your note content here...
```

### Books

Create book notes in the `_books` directory with the following front matter:

```markdown
---
title: Book Title
author: Book Author
cover: /assets/images/books/book-cover.jpg
date_read: YYYY-MM-DD
rating: 5  # 1-5
tags: [tag1, tag2]
---

Your book notes here...
```

### Using Wikilinks

Link to other notes using double square brackets:

```markdown
Check out this [[note-title]] for more information.

I read this interesting [[Book: Book Title]].
```

## Customization

### Site Configuration

Edit `_config.yml` to customize your site settings:

- Site title and description
- Social media links
- Default settings for collections
- And more!

### Styling

The theme uses Sass for styling:

- Main variables are in `_sass/garden/_variables.scss`
- Edit colors, fonts, and spacing to match your preferences
- Add custom CSS in `assets/css/main.scss`

### Adding Pages

Create new pages in the root directory or in the `_pages` directory with the appropriate front matter:

```markdown
---
layout: page
title: About
permalink: /about/
---

Your page content here...
```

## Deployment

### GitHub Pages

This repository is configured for deployment to GitHub Pages using GitHub Actions.

1. Make sure your repository is named `yourusername.github.io` or update the `baseurl` in `_config.yml` accordingly.

2. **Generate data files for search and graph visualization**:

```bash
# Run the data files generation script
./generate-data-files.sh
```

This script will:
- Build the site locally with plugins enabled
- Generate the search-index.json and graph-data.json files
- Copy these files to the root directory

3. Push your changes to GitHub:

```bash
# Initialize git repository if not already done
git init

# Add all files
git add .

# Commit changes
git commit -m "Initial commit"

# Add your GitHub repository as remote
git remote add origin https://github.com/yourusername/yourusername.github.io.git

# Push to GitHub
git push -u origin main
```

3. GitHub Actions will automatically build and deploy your site to GitHub Pages.

4. Your site will be available at `https://yourusername.github.io/`

5. You can check the status of the deployment in the "Actions" tab of your GitHub repository.

### Troubleshooting GitHub Pages Deployment

If you encounter issues with GitHub Pages deployment, check the following:

1. **Ruby Version**: The workflow is configured to use Ruby 3.0. This is specified in both the GitHub workflow file and the `.ruby-version` file.

2. **Gemfile.lock**: Make sure you have a `Gemfile.lock` file in your repository. If not, generate one locally with:

   ```bash
   bundle lock --update
   ```

3. **Gem Compatibility**: The Gemfile specifies compatible versions of gems to avoid dependency issues. If you're experiencing problems, try updating the Gemfile with specific versions:

   ```ruby
   gem "github-pages", "~> 228"
   gem "jekyll", "~> 3.9.3"
   ```

4. **GitHub Workflow**: The `.github/workflows/github-pages.yml` file is configured to:
   - Use Ruby 3.0
   - Update RubyGems to version 3.3.22
   - Install dependencies with proper caching
   - Build and deploy the site to the gh-pages branch

5. **Permission Issues**: If you see errors like "Permission denied to github-actions[bot]", you need to set up a deploy key:

   ```bash
   # Run the deploy key setup script
   ./setup-deploy-key.sh
   ```

   This script will:
   - Generate an SSH key pair
   - Show you how to add the public key as a deploy key in your GitHub repository
   - Show you how to add the private key as a secret named DEPLOY_KEY in your GitHub repository

   After adding both keys to your GitHub repository, the GitHub Actions workflow will be able to deploy your site.

6. **Common Errors**:
   - If you see errors about RubyGems version incompatibility, check that the workflow is updating RubyGems properly.
   - For native extension build failures, make sure the workflow has the necessary build tools installed.
   - For permission errors (403), make sure you've set up the deploy key correctly.

### Cloudflare Pages

1. Connect your GitHub repository to Cloudflare Pages.

2. Use the following build settings:
   - Build command: `jekyll build`
   - Build output directory: `_site`

3. Add environment variables:
   - `JEKYLL_ENV`: `production`

## Credits

- Inspired by [Maggie Appleton's digital garden](https://maggieappleton.com/)
- Built with [Jekyll](https://jekyllrb.com/)
- Graph visualization powered by [D3.js](https://d3js.org/)
- Search functionality using [Lunr.js](https://lunrjs.com/)

## License

This project is open source and available under the [MIT License](LICENSE).
