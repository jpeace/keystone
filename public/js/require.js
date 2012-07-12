(function() {
  var modules = [];

  var libACache = null;
  var libAFunc = function() {
    
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
  }
  modules.libA = function() {
    if (libACache === null) {
      libACache = libAFunc();
    }
    return libACache;
  }

  var libBCache = null;
  var libBFunc = function() {
    
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
  }
  modules.libB = function() {
    if (libBCache === null) {
      libBCache = libBFunc();
    }
    return libBCache;
  }


  
  window.require = function(path) {
    return modules[path]();
  }
})();