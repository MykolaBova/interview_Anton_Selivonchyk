Using the data from Google places https://developers.google.com/places/web-service/search create a simple app to save places based on city and have the CRUD operations on them.

Implementation:

iOS:
1. Have a list with places based on city, have a combo or textfield to select the city or use current location from GPS and show places only from that location
2. Populate the list by doing a search with let's say 5km radius and save the results to the server and on a future search match the existing ones and override the data only if the user did not change the data from your app, a simple dirty flag will do. On first edit on a place you fetch the details using the details api.
3. Implement CRUD operations on each of these places, also show images
4. Implement various filters on the list, choose the fields you think it would matter for you as a traveler :)

Web:
5. Post data to the server and persist them.
6. Show the list of places based on a location
7. Ability to edit some basic fields
8. In the list view show a map with all the places. I think this will help https://develpers.google.com/maps/documentation/javascript/tutorial if not google is your friend :)
9. Export places to xml or any format you want

Technologies to use:

Client:
Objective-C
realm.io
Server:
PostgreSQL
Django or Flask
SQlAlchemy
REST implementation


Web side is Optional.
Goal is not to finish the project, but demonstrate coding skills, git commits etc.
