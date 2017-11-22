// This code add css in selected link



jQuery.noConflict();
jQuery(document).ready(function($){
  var currentUrl = window.location.pathname
  var full_path = currentUrl + window.location.search;
  if (window.location.search.indexOf('?cat=1') > -1 ||  window.location.search.indexOf('?cat=2') > -1 || window.location.search.indexOf('?cat=5') > -1 || full_path == '/courses ')
  {
    $('.dropdown').addClass('red')
    var currentMenu = $("a[href='" + full_path +"']");
    $(currentMenu).addClass('red')
  }
  else if (window.location.search.indexOf('?cat=3') > -1)
  {
    var currentMenu = $("a[href='/courses?cat=3']");
    $(currentMenu).addClass('red')
  }
  else if (window.location.search.indexOf('?cat=4') > -1)
  {
    var currentMenu = $("a[href='/courses?cat=4']");
    $(currentMenu).addClass('red')
  }
  else if (window.location.search.indexOf('?cat=') > -1 || window.location.pathname == '/courses')
  {
    $('.dropdown').addClass('red')
  }
  else if (full_path.indexOf('types') > -1)
  {
    $('.dropdown').addClass('red')
  }
  else if (full_path.indexOf('/instructors/') > -1)
  {
    var currentMenu = $("a[href='/instructors']");
    $(currentMenu).addClass('red')
  }
  else
  {
    var currentMenu = $("a[href='" + full_path +"']");
    var a = $( currentMenu ).closest('ul').attr('class');
    if (a == 'nav'){
    $(currentMenu).addClass('red')
  }
  }
});
