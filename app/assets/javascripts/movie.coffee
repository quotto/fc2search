# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
add_user = -> 
  $user_input = $(event.target).parent().parent()
  if $user_input.children().length < 10 
    $new_user_input = $('<div></div>')
    $new_user_input.append('<input type="text" class="form-control" name="user[]" placeholder="除外するユーザを指定"></input>')
    $new_user_input.append('<span class="glyphicon glyphicon-plus user-plus" aria-hidden="true" onclick="add_user()"></span>')
    $new_user_input.append('<span class="glyphicon glyphicon-minus user-minus" aria-hidden="true" onclick="remove_user()"></span>')
    $new_user_input.appendTo($user_input)

remove_user = ->
  $(event.target).parent().remove()

scroll_top = ->
  $('body').animate({scrollTop:0})

scroll_bottom = ->
  $('body').animate({scrollTop:$('.pagination').offset().top})


window.add_user = add_user
window.remove_user = remove_user
window.scroll_top = scroll_top
window.scroll_bottom = scroll_bottom
