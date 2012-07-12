(function() {
  var init = function() {
    console.log('Lib B Init');
  }

  var doSomething = function() {
    console.log('Lib B DoSomething');
  }

  init();

  return {
    doSomething : doSomething
  }
})();