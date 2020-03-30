# Marvel Combat Arena

### About
  - This web application was created using Marvel public API (https://developer.marvel.com) for my personal, noncommercial use and is intended for informational and entertainment purposes only.
  - All data is provided by Marvel.

### Tech

* ruby '2.7.0'
* rails '6.0.2'
* bootstrap '4.3.1'

### Setup
- Clone this repository.
- In config folder create a secrets.yml file
- You will need to get your own public and private key from Marvel (https://developer.marvel.com/documentation/getting_started)
- Once you have them, place them in the secrets.yml file like this:
```sh
development:
  marvel_public_key: YOUR_MARVEL_PUBLIC_KEY
  marvel_private_key: YOUR_MARVEL_PRIVATE_KEY
```
- make sure you have bootstrap installed or some of the styling might be of:
```sh
$ yarn add bootstrap@4.3.1 jquery popper.js
```
Start you server and just go to "localhost:3000"
```sh
$ rails server
```


### Game rules
 - You must provide 2 Marvel character names to do battle in the arena and a SEED number between 1-9.
 - Once you submit, the system will retrieve the bio (description) for each character. In each description it will look for the word at the position of the SEED number.
 - The winner of the battle is the character whose WORD has the most characters EXCEPT if either character's WORD is a MAGIC WORD “Gamma” or “Radioactive”, in which case they automatically Win.

### What I have learned
It has been a while since I used my personal computer for coding and since one of the requirements was a specific version of Ruby, I had to update it.
That caused a number of other dependcy issues and I ended up updating my OS (very time consuming and it took a big part of my project dedicated time).
This was my first time building a connection with an API so that was my biggest concern. While looking for the best/easy to use HTTP client for Ruby I found ['Faraday'](https://www.ruby-toolbox.com/categories/http_clients) has the best reviews and is being regulaty maintained. There was also plenty of examples online (some even with Marvel API). Using examples and Marvel documentation it was not long before I got a succesfull response so that ended up being easier then I expected.
I wanted this project to be easy to setup and since the game is realtively simple I decided to work without a database. It was a useful exercise to try to recreate/overwrite some rails model methods and validations without an actual table.
For styling I used a combination of bootstrap and custom styling. Since I mostly do back-end development or use already set styling in existing projects, it was useful (and frustrating at times) to get some practice in setting up a new site.


### Todos

 - Write tests
 - Some characters are not loading even thought the name is correctly spelled (find out if that can be improved)
 - There is other improvements in the code and styling I wish to do, but since this is a time limited challenge, I have to stop for now

### Credits
- Data provided by Marvel [©2020 MARVEL](https://developer.marvel.com)
- [Spiderman vector](https://png.is/f/miles-morales-superman-vs-the-amazing-spider-man-spider-woman-spider-man-2099-spiderman/5257967607742464-201902131555.html)
- [City photo - Matthew Henry](https://unsplash.com/@matthewhenry?utm_medium=referral&utm_campaign=photographer-credit&utm_content=creditBadge)
