(function() {
  var init = function() {
    console.log('Lib A Init');
  }

  var doSomething = function() {
    console.log('Lib A DoSomething');
  }

  init();

  return {
    doSomething : doSomething
  }
})();