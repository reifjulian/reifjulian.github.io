# My website

My website is based on the [Minimal Mistakes Jekyll theme](https://github.com/mmistakes/minimal-mistakes). It uses the `contrast` skin and is setup to use Minimal Mistakes as a remote theme.

I've made the following custom adjustments:
  - Added code to `/assets/css/main.scss` that:
    - turns off blue underlines for hyperlinks
	- makes the avatar larger in the author sidebar
	- removes fading from the author sidebar
  - Commented out code in `/_includes/footer.html` to remove the RSS feed link from the bottom of the pages
  - Added code to `/_includes/head/custom.html` to use the favicon `/assets/images/favicon.ico`
  - Added code to `/_includes/head/custom.html` to use custom syntax highlighting (VS Code Light+)
    - Syntax CSS (`assets/css/syntax.css`) uses colors matching the VS Code Light+ theme
  - Added code to `/_includes/head/custom.html` to use newer Font Awesome icons (version 6.5.2)
  - Added Google Analytics code to `/_includes/head/custom.html`

To deploy a local build:
  1. Compile locally using Ruby: `bundle exec jekyll build`
  1. Copy contents of `_sites/` to root folder
  1. Copy `CNAME` to root folder
