//ScreenFreeze is funtion that go through a displayed items and 
function screenFreeze() {

    for(i = 0; i < displayed.length; i++)
    {
        if(!displayed[i].frozen)
        {
            freeze();
        }

        else
        {
            unfreeze();
            break;
        }
    }
}

function freeze()
{
    for(i = 0; i < displayed.length; i++)
    {
        displayed[i].frozen = true;

        $('#' + displayed[i].tile + "freeze").css('opacity', '1');

    }
    
    $('#freezeBtn').css('opacity', '1');
    screenFrozen = true;
}

function unfreeze()
{
    for(i = 0; i < displayed.length; i++)
    {
        displayed[i].frozen = false;

        $('#' + displayed[i].tile + "freeze").css('opacity', '0.5');
    }

    $('#freezeBtn').css('opacity', '0.35');
    screenFrozen = false;
}

function tileFreeze(){

    var tile = arguments[0].id;

    for(i = 0; i < displayed.length; i++)
    {
        if(displayed[i].tile === tile && !displayed[i].frozen)
        {
            displayed[i].frozen = true;

            $('#' + tile + "freeze").css('opacity', '1');
        }

        else if(displayed[i].tile === tile && displayed[i].frozen)
        {
            displayed[i].frozen = false;

            $('#' + tile + "freeze").css('opacity', '0.5');
        }
    }
}

//Handles a keyboard input in this case a space.
//When pressed it trigger screenFreeze() and  togglePlay();
$(document).keypress(function(e){
    if ((e.which && e.which == 32) || (e.keyCode && e.keyCode == 32)) {
        togglePlay();
        screenFreeze();
        return false;
    }

    else 
    {
        return true;
    }
 });

$('').click(function(){   //Extra onclick function incase we decide to use a button. 
    togglePlay();             
    screenFreeze();
    return false;
});

// This function animates the play and pause pictures 
// The two pictures fade in and out. 
function togglePlay(){
    var $elem = $('#player').children(':first');
    $elem.stop()
    .show()
    .animate({'marginTop':'-175px','marginLeft':'-175px','width':'350px','height':'350px','opacity':'0'},function(){
         $(this).css({'width':'100px','height':'100px','margin-left':'-50px','margin-top':'-50px','opacity':'1','display':'none'});
    });
    $elem.parent().append($elem);
}
   