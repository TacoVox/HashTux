#CouchDB database
##Startup
To startup simply start the database supervisor:
```erlang
db_sup:start_link().
```

##General usage
To send messages to the server simply make gen_server calls to the responsible dispenser serv <b>db_serv</b>.
The call will return you the reference (PID) of the started worker process.
So you can pattern match for the result in your receive.
```erlang
Ref = gen_serv:call(db_serv, {get_posts, "your_hashtag"}),
receive {Ref, Result} -> Result end.
```

##Supported calls
###Read operations (for posts)
```erlang
{posts_exist, "Hashtag"}
```
* Checks if there are any posts for a specific Hashtag
* Returns a true or false atom

```erlang
{get_posts, "Hashtag"}
```
* "Hashtag" is the Hashtag you want to search for
* Returns all available posts in a list of JSX JSON results

```erlang
{get_posts, "Hashtag", [{option1, Value1}, {option2, Value2}, {option3, Value3}, {optionN, ValueN}]}
```
* As above but with search (multiple) options

#### Search options
```erlang
{content_type, [<<"image">>, <<"text">>, <<"video">>]}
```
* The content_type needs to be send as a list with binary strings

```erlang
{service, [<<"twitter">>, <<"instagram">>, <<"youtube">>]}
```
* The services takes the different services we have in a list with binary strings

```erlang
{language, <<"en">>}
```
* The language is a binary string

```erlang
{timeframe, StartTime, EndTime}
```
* The timeframe in between the post has to be
* StartTime and EndTime are integers

```erlang
{minimum_posts, Amount}
```
* The minimum amount of posts the database should return or nothing

```erlang
{limit, Int}
```
* Gives you back as many result as you specified in the Int

###Read operations (for stats)
```erlang
{get_stats, SearchField, [Options]}
```
* List of the popular hashes (maximum as big as specified)

#### Stats Search Field
* Is always a string
* The following strings are possible plus you need to add either: "_today","_week"."_month","_year" to the strings below.

```erlang 
"search_term"
```

```erlang
"browser"
```

```erlang
"platform"
```

```erlang
"browser_version"
```
```erlang
"platform_browser"
```

#### Stats options
* For getting statistics you can online specify one Option
* Leaving the Option empty you will get the amount of requests of the DB
* The following are supported:

```erlang
{limit, Int}
```

###Write operations
```erlang
{add_doc, Content}
```
* Adds document(s) (which must be in JSX JSON representation) to the database
* Content is a list of JSX JSON Obj. -> [[{<<"search_term">>, <<"jerker">>}, {<<"lastname">>, <<"ericsson">>}], [...]]
* Returns a true or false atom

```erlang
{add_habit_doc, Content}
```
* Adds ONE document to the user habit data database
* Content is a JSX JSON Obj.
