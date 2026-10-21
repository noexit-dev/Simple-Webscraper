require 'selenium-webdriver' #for browsing
require 'nokogiri' # for parsing HTML
require 'json' #for parsing JSON


class Main 
    
    def initialize()

        books_title = []
        books_rating = []
        books_price = []
        books_status = []
        books_img = []
        

        # Initialize Chrome options
        options = Selenium::WebDriver::Chrome::Options.new

        # Add the custom user agent argument
        options.add_argument('--user-agent=Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36')

        options.add_argument('--headless');

        driver = Selenium::WebDriver.for :chrome, options: options

        # Navigate to a URL
        driver.get "https://books.toscrape.com/catalogue/category/books_1/index.html"
        
        for i in 1..50

            #grab data with nokogiri

            doc = Nokogiri::HTML(driver.page_source)

            books = doc.css('ol.row li')

            books.each do |item|

                # Scope your selectors to 'item' to get data for that specific product
                rating = item.at_css('p.star-rating')['class']
                title = item.at_css('h3 a')['title'] || item.at_css('h3 a').text
                price = item.at_css('.price_color').text
                availability = item.at_css('.instock.availability').text.strip
                image_url = item.at_css('.image_container img')['src']

                #info pasted to console 
                puts "Product: #{title}"

                case rating
                when "star-rating One" 
                    puts "Rating: 1/5"
                    books_rating << 1
                when "star-rating Two"
                    puts "Rating: 2/5"
                    books_rating << 2
                when "star-rating Three"
                    puts "Rating: 3/5"
                    books_rating << 3
                when "star-rating Four"
                    puts "Rating: 4/5"
                    books_rating << 4
                when "star-rating Five" 
                    puts "Rating: 5/5"
                    books_rating << 5
                else
                    puts "No match found"
                end

                puts "Price: #{price}"
                puts "Status: #{availability}"
                puts "Image: #{image_url}"
                puts "--------------------------"

                #parse to JSON
                books_title << title
                books_price << price
                books_status << availability
                books_img << image_url

            end
            
            if i != 50
                #click element asynchronous
                wait = Selenium::WebDriver::Wait.new(timeout: 15)
                element_next = wait.until do
                    link = driver.find_element(css: "li.next > a")
                    link if link.displayed? && link.enabled?
                end
                element_next.click
            end
            
        end
        
        #generate JSON

        array_of_hashes = books_title.map.with_index do |title, index|
            { Product: title, Rating: books_rating[index], Price: books_price[index], Status: books_status[index], Image: books_img[index] }
        end

        pretty_json = JSON.pretty_generate(array_of_hashes)

        puts pretty_json

        File.write("books.json", pretty_json)

        # sleep 100

        # # Close the browser
        driver.quit

    end
 
end

# creating object  
obj = Main.new
