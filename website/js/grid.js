/**
 * This Javascript file handles the generating of the grid.
 */

/**
 * A function that fills the displayed array with the number of items that
 * are needed to fill up the grid. If there is not enough items, it gets filled
 * with all the availible items.
 */

function initDisplayed()
{                
    if(displayed.length > 0)
    {
        displayed.length = 0;
    }

    for(k = 0; k < totalItems; k++) {

        if(items.length < 1)
            break;

        var index = Math.floor((Math.random() * items.length));

        displayed.push(items[index]);
        items.splice(index, 1);
    }
}

function initGrid() 
{
    var grid = $('#grid');
    var count = 0;

    for(i = 0; i < gridHeight; i++) {

        var cols = "";

        for(j = 0; j < gridWidth; j++) {

            if(count >= displayed.length) 
            {

                cols = cols + 
                    "<div class='col-xs-" +
                    (12/gridWidth) + 
                    " col-fill fixitem' style='background-image:url();' id='tile" +
                    count +
                    "'></div>";

                count++;
            }

            else if(displayed[count].service === "instagram") 
            {

                if(displayed[count].type === "image")
                {


                    cols = cols + 
                        "<div class='col-xs-" +
                        (12/gridWidth) + 
                        " col-fill fixitem' style='background-image:url(" +
                        displayed[count].url +
                        ");' id='tile" + count + "'>" +
                        "<p class='usernameimage'><a class='greytext' href='" +
                        displayed[count].userlink + "' target='_blank'>@" +
                        displayed[count].username + "</a></p>" +
                        "<button type='submit' class='itemfreezebtn' id='tile" + count +
                        "freeze' onclick='tileFreeze(" + "tile" + count + ")'>" +
                        "<img src='images/freeze.png' width='30px' height='30px'>" + "</button>" +
                        "</div>";

                    displayed[count].tile = "tile" + count;
                    count++;

                }

                else if(displayed[count].type === "video")
                {
                    cols = cols +
                        "<div class='col-xs-" + 
                        (12/gridWidth) + 
                        " col-fill' style='background-image:url('');' id='tile"+
                        count + "'>" +
                        "<video width='100%' height='100%' autoplay loop muted controls src='" +
                        displayed[count].url + 
                        "' style='object-fit: fill; top: 0; position: absolute;'></video>" +
                        "<p class='usernameimage'><a class='greytext' href='" +
                        displayed[count].userlink + "' target='_blank'>@" +
                        displayed[count].username +
                        "</a></p>" +
                        "<button type='submit' class='itemfreezebtn' id='tile" + count +
                        "freeze' onclick='tileFreeze(" + "tile" + count + ")'>" +
                        "<img src='images/freeze.png' width='30px' height='30px'>" + "</button>" +
                        "</div>";

                    displayed[count].tile = "tile" + count;
                    count++;
                }

            }

            else if(displayed[count].service === "twitter")
            {

                if(displayed[count].type === "text")
                { 
                    cols = cols +
                        "<div class='col-xs-" +
                        (12/gridWidth) + 
                        " col-fill fixitem' id='tile" +
                        count + "'>" +
                        "<div class='twittertext'><p>" +
                        displayed[count].text +
                        "<p class='usernametweet'><a class='greytext' href='" +
                        displayed[count].userlink + "' target='_blank'>@" +
                        displayed[count].username + 
                        "</a></p></p></div>" +
                        "<button type='submit' class='itemfreezebtn' id='tile" + count +
                        "freeze' onclick='tileFreeze(" + "tile" + count + ")'>" +
                        "<img src='images/freeze.png' width='30px' height='30px'>" + "</button>" +
                        "</div>";

                    displayed[count].tile = "tile" + count;
                    count++;
                }

                else if(displayed[count].type === "image")
                {
                    cols = cols + 
                        "<div class='col-xs-" +
                        (12/gridWidth) + 
                        " col-fill fixitem' style='background-image:url(" +
                        displayed[count].url +
                        ");' id='tile" +
                        count + "'>" +
                        "<div class='twitterimagetext'><p>" +
                        displayed[count].text +
                        "<p class='usernametweet'><a class='greytext' href='" +
                        displayed[count].userlink + "' target='_blank'>@" +
                        displayed[count].username + 
                        "</a></p></p></div>" +
                        "<button type='submit' class='itemfreezebtn' id='tile" + count +
                        "freeze' onclick='tileFreeze(" + "tile" + count + ")'>" +
                        "<img src='images/freeze.png' width='30px' height='30px'>" + "</button>" +
                        "</div>";

                    displayed[count].tile = "tile" + count;
                    count++;
                }
            }
            
            else if(displayed[count].service === "youtube")
            {
                cols = cols +
                    "<div class='col-xs-" + 
                    (12/gridWidth) + 
                    " col-fill' style='background-image:url('');' id='tile"+
                    count + "'>" +
                    "<iframe width='100%' height='100%' frameborder='0' src='" +
                    displayed[count].url + "" +
                    "' style='object-fit: fill; top: 0; position: absolute;'></iframe>" +
                    "<p class='usernameimage'><a class='greytext' href='" +
                    displayed[count].userlink + "' target='_blank'>@" +
                    displayed[count].username +
                    "</a></p>" +
                    "<button type='submit' class='itemfreezebtn' id='tile" + count +
                    "freeze' onclick='tileFreeze(" + "tile" + count + ")'>" +
                    "<img src='images/freeze.png' width='30px' height='30px'>" + "</button>" +
                    "</div>";

                displayed[count].tile = "tile" + count;
                count++;
            }
        }

        grid.html(grid.html() +
            "<div class='row-grid-" +
            (12/gridHeight) + "' id='row" +
            i + "'>" + cols + "</div>");
    }
}