$(document).ready(function(){
  $('form.play-card').live("ajax:success", function(event, data){
    $("#game-page").html(data);
  });
  
  $('form.new-trick').live("ajax:success", function(event, data){
    $("#game-page").html(data);
  });  

  $('form.new-round').live("ajax:success", function(event, data){
    $("#game-page").html(data);
  });

  $('form.fill-game').live("ajax:success", function(event, data){
    $("#game-page").html(data);
  });

  $('form.pass-cards').live("ajax:success", function(event, data){
    $("#game-page").html(data);
  });

  $('form.choose-to-pass').live("ajax:success", function(event, data){
    $("#my-hand").html(data);
  });


  $('form.fill-passing-sets').live("ajax:success", function(event, data){
    $("#game-page").html(data);
  });
  
  
  
  
});
