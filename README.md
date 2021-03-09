# My website

My website is based on the [Minimal Mistakes Jekyll theme](https://github.com/mmistakes/minimal-mistakes). It uses the `contrast` skin and is setup to use Minimal Mistakes as a remote theme.

I've made the following custom adjustments:
  - Added code to `/assets/css/main.scss` that:
    - turns off blue underlines for hyperlinks
	- makes the avatar larger in the author sidebar
	- removes fading from the author sidebar
  - Added code to `/_includes/head/custom.html` to use the favicon `/assets/images/favicon.ico`
  - Commented out code in `/_includes/footer.html` to remove the RSS feed link from the bottom of the pages
  