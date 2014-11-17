$(document).ready(function(){

  setTimeout(CardGames.autoplay, 2000);

  $('.choosable').live("click", function(){
    var $cardId = this.getAttribute('card-id');
    $.post(window.location.pathname + "/toggle_passing_status?card=" + $cardId, function(html){
      $(".my-hand").html(html);
    });
  });

  $('.chosen').live("click", function(){
    // var $cardId = $(this).data('card-id');
    var $cardId = this.getAttribute('card-id');
    $.post(window.location.pathname + "/toggle_passing_status?card=" + $cardId, function(html){
      $(".my-hand").html(html);
    });
  });

  $('.playable').live("click", function(){
    var $cardId = this.getAttribute('card-id');
    $.post(window.location.pathname + "/play_one_card?card=" + $cardId, function(html){
      $(".game-page").html(html);
      CardGames.autoplay();
    });
  });

  $('form.skip-reload').live("ajax:success", function(event, html){
    CardGames.autoplay();
  });

  $('form.immediate-reload').live("ajax:success", function(event, html){
    $(".game-page").html(html);
    CardGames.autoplay();
  });

  $('form.remove-pass-button').live("ajax:success", function(event){
    $(".pass-button").remove();
    CardGames.autoplay();
  });

  $("#toggle-last-trick").live("click", function(){
    $(".previous-trick-cards").slideToggle("fast");
  });
});

CardGames = {

  autoplay: function(){
    $.getJSON(window.location.pathname, function(game){
      if (game.shouldReloadPreviousTrick){
        CardGames.reloadPreviousTrick();
      }
      if (game.shouldReloadAndJustWait){
        CardGames.reloadAndJustWait();
      }
      else if (game.shouldReloadWaitAutoplay){
        CardGames.reloadWaitAutoplay();
      }
      else if (game.computerShouldPlay){
        CardGames.playAsComputer();
      }
      else if (game.shouldStartNewRound){
        var $newRoundDelay
        if (game.isStartingFirstRound) {
          $newRoundDelay = 0;
        }
        else {
          $newRoundDelay = 3000;
        }
        CardGames.reloadAndJustWait();
        setTimeout(CardGames.startNewRound, $newRoundDelay);
      }
      else if (game.shouldStartNewTrick){
        var $newTrickDelay
        if (game.isStartingFirstTrick) {
          $newTrickDelay = 0;
        }
        else {
          $newTrickDelay = 2000;
        }
        CardGames.reloadAndJustWait();
        setTimeout(CardGames.startNewTrick, $newTrickDelay);
      }
      else if (game.shouldPassCards){
        CardGames.passCards();
      }
    });
  },

  reloadAndJustWait: function(){
    $.post(window.location.pathname + "/reload", function(html){
      $(".game-page").html(html);
    });
  },

  reloadWaitAutoplay: function(){
    $.post(window.location.pathname + "/reload", function(html){
      $(".game-page").html(html);
      setTimeout(CardGames.autoplay, 1000);
    });
  },

  playAsComputer: function(){
    $.post(window.location.pathname + "/play_one_card", function(html){
      $(".game-page").html(html);
      CardGames.autoplay();
    });
  },

  startNewRound: function(){
    $.post(window.location.pathname + "/new_round", function(html){
      $(".game-page").html(html);
      CardGames.autoplay();
    });
  },

  startNewTrick: function(){
    $.post(window.location.pathname + "/new_trick", function(html){
      $(".game-page").html(html);
      CardGames.autoplay();
    });
  },

  passCards: function(){
    $.post(window.location.pathname + "/pass_cards", function(html){
      CardGames.autoplay();
    });
  },

  reloadPreviousTrick: function(){
    $.post(window.location.pathname + "/reload_trick", function(html){
      $(".previous-trick").html(html);
    });
  }

}
