#Protocols & DataType specification
##Social Media Post Datatype / Document
**Insert MARCO's TABLE here instead of following list**

This is the format in which we store the social media posts in the database or return them to the client.
We usually pass several posts around at a time. Hence generally the posts need to be wrapped in a list:
```erlang
[[Document1], [Document2], [Document3], [DocumentN]].
```
The format of the document is the following (written in Erlang compatible with PSX JSON):
```erlang
[{<<"search_term">>, <<"The search term without a hashtag">>},
{<<"service_id">>, <<"Post ID in external service">>},
{<<"user_id">>, <<"The User ID in external service">>},
{<<"username">>, <<"@UserName">>},
{<<"display_name">>, <<"The Real Name">>},
{<<"service">>}, <<"twitter or youtube or instagram">>},
{<<"content_type">>, <<"image or video or text">>},
{<<"resource_link_low">>, <<"resource link in low res">>},
{<<"resource_link_high">>, <<"resourch link in high res">>},
{<<"insert_timestamp">>, the time the document is stored in the DB},
{<<"timestamp">>, timestamp_as_integer},
{<<"text">>, <<"The content text">>},
{<<"language">>, <<"the language like en">>},
{<<"location">>, {lat, long, place},
{<<"view_count">>, view_count_as_integer},
{<<"like_count">>, like_count_as_integer},
{<<"date_string">>, <<"Readable date string"">>},
{<<"profile_image_url">>, <<"URL of profile image">>},
{<<"tags">>, [The Tags]}]
```

##Format of search requests to the backend server
Requests to the backend server are REST-like, except that for practical reasons we use POST rather than GET for all requests because we have quite a lot of options and data sent from the web application (that we send as JSON in the POST body), that would otherwise result in a very long query string.<br />
The functions provided in the file /website/include/request.php can be used to generate a properly structured request by first using the build_request_options() function if needed and then making the actual request via the request() function. However, for frontend development, we recommend simply accessing the ajax interfaces discussed below. 

Here is the format of the request:
 - Use HTTP POST requests.
 - Supply the search term as the path in the request, for example http://localhost:8080/my_search_term
 - In the request body, provide a JSON list of two objects: [options, user_habit_data]. Note that in Erlang the keys in each key-value tuple is converted to an atom, but while in JSON they are still strings.

Options - a JSON object with the following key-value pairs:
 - request_type: "search" for initial search (more results) or "update" for subsequent (ajax) requests. Use "heartbeat" to trigger precaching.
 - service: a list, any combination of "twitter", "instagram", "youtube". Omitting this options means allow all.
 - history_timestamp, an epoch timestamp which the history search will center around. Omitting this options means search for recent content.
 - content_type: a list, any combination of "image", "text", "video".  Omitting this options means allow all.
 - language: two lowercase characters representation. Omitting this options means allow all.

User Habit Data - a JSON object with user habit data.
Currently we let the PHP application supply the following key-value pairs. (The backend server should not care very much about what we throw in here, if we decide to connect from a new kind of client - but now this is what is used for the statistics page as well).
 - timetamp: Unix epoch time, number
 - session_id: PHP session string
 - ip_address: String
 - platform: Platform, free text
 - browser: Web browser, free text
 - browser_version: Web browser version, free text

Example of the whole [options, user_habit_data] request body: 
```json
[{"request_type":"search",
  "services":["twitter", "instagram"],
  "content_type":["images"],
  "language":"en"},
 {"timestamp":1447435268,
  "session_id":"1t8iv8lt4c54h9ht3gc1ml2997",
  "ip_address":"178.174.190.192",
  "browser":"Firefox",
  "browser_version":"42.0",
  "platform":"Windows"}] 
```

When decoded to erlang by JSX, the option part looks like this:
```erlang
[{"request_type", <<"search">>},
  {"services", [<<"twitter">>, <<"instagram">>]},
  {"content_type", ["<<images">>]},
  {"language", <<"en">>}]
```

##Format of user statistics data requests to the Erlang backend
The above section applies, except the available options. In the options object, set the request_type option to "stats". Use "/" followed by the document name (example: "/search_term_year") as the term. 

##Ajax requests to the Erlang backend
We make AJAX requests through our PHP application. This allows user habit data to be appended and the PHP application also keeps track of which backend server is preferred and available. Currently we have two different interfaces that forward requests to the backend server.
###ajax.php
By querying ajax.php via HTTP GET, which enables setting the request_type option as a GET parameter. (The file ajax.php then sends a HTTP POST request with the correct format that the backend server expects. Right now these parameters are supported:
###ajax_post.php
By querying ajax_post.php via HTTP POST, with the option object in the POST body, you can make a more customized request. This is recommended for any requests except the most simple ones. Note that this requires specifying at least the request_type parameter in the options object! The user habit data will be appended before the request is sent to the backend server.
