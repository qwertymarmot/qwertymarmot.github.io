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

- Ruby version 2.5.0 or higher
- RubyGems
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

This repository is already configured for deployment to GitHub Pages using GitHub Actions.

1. Make sure your repository is named `yourusername.github.io` or update the `baseurl` in `_config.yml` accordingly.

2. Push your changes to GitHub:

```bash
# Initialize git repository if not already done
git init

# Add all files
git add .

# Commit changes
git commit -m "Initial commit"

# Add your GitHub repository as remote
git remote add origin https://github.com/qwertymarmot/qwertymarmot.github.io.git

# Push to GitHub
git push -u origin main
```

3. GitHub Actions will automatically build and deploy your site to GitHub Pages.

4. Your site will be available at `https://qwertymarmot.github.io/`

5. You can check the status of the deployment in the "Actions" tab of your GitHub repository.

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
