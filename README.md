# UChicago Human-Robot Interaction Lab Official Website

The template for this website is the [Helios](https://html5up.net/helios) template from [HTML5 UP](https://html5up.net/) and customized by [Sarah Sebo](https://sarahsebo.com/index.html) for the UChicago HRI Lab website. 

## New Members

In order to add your picture and a link to your website on the "People" page of the site make the following changes and then make a pull request so your changes can be approved and incorporated into the official site.

1. Select a photo of yourself that you would like to have posted on the website. Make sure that it is *exactly* square (width = height). 

2. Put your photo in the `images/people` directory where the name of the image file is your name. 

3. Copy the following html and paste it directly above the commented line `<!-- NEW [STUDENT] ADD HERE -->`. Pay attention to where you put your html, and that your put yourself above the `<!-- NEW UNDERGRAD ADD HERE -->` if you're an undergrad or `<!-- NEW PHD STUDENT ADD HERE -->` if you're a PhD student, etc. 
   
   1. There are two options for the html, depending on whether you want to link your personal website, LinkedIn or something else with your name. The first option is above, where a website is linked. The second option, where a website is not linkedin, is listed below. 

```
                            <article class="col-3 col-12-mobile special">
                                <a class="image people"><img src="images/people/IMAGE_FILE_NAME" alt="" /></a>
                                <header>
                                    <h3><a href="INSERT WEBSITE URL HERE">YOUR NAME</a></h3>
                                </header>
                            </article>
```

```
                            <article class="col-3 col-12-mobile special">
                                <a class="image people"><img src="images/people/IMAGE_FILE_NAME" alt="" /></a>
                                <header>
                                    <h3>YOUR NAME</h3>
                                </header>
                            </article>
```

4. Once you've pasted the html in the appropriate place:

    1. replace the `IMAGE_FILE_NAME` with the image file name that you just put in the `images/people` directory (remember to include the extension, e.g., .png, jpg)

    2. replace `YOUR NAME` with your name

    3. if you have a website, and you want this page to link to it, replace the two `#` with your website url

5. Finally, commit your changes and make a pull request so that your changes are approved and reflected on the actual website.

## How to run a simple HTTP server to view the site locally

First, in a terminal, `cd` into this directory (uchicago-intro-robotics-winter-2021-website), then run:
```
python -m http.server
```

## TODOs

- Get a new pic to be the landing image that's of the actual UChicago HRI lab space
- Add first news items (and format the news page and the news on the index page nicely)
- Add content to the research page
- Add content to the join us page
- Add some research highlights to the index page
- Add lab address / location to the footer