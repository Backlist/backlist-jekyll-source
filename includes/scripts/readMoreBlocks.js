(function(exports) {
  var permalink;
  var categories;

  function shuffle(array) {
    var currentIndex = array.length, temporaryValue, randomIndex;

    // While there remain elements to shuffle...
    while (0 !== currentIndex) {

      // Pick a remaining element...
      randomIndex = Math.floor(Math.random() * currentIndex);
      currentIndex -= 1;

      // And swap it with the current element.
      temporaryValue = array[currentIndex];
      array[currentIndex] = array[randomIndex];
      array[randomIndex] = temporaryValue;
    }

    return array;
  }

  function shrinkList(list) {
    list = shuffle(list);

    if (list.length > 3)
      return list.slice(0, 3);

    return list;
  }

  function buildCategoryCollection(data) {
    if (data.length > 1) {
      var lists = new Array();

      data.forEach(function(list) {
        if (list["list_permalink"] !== permalink)
          lists.push(list);
      });

      lists = shrinkList(lists);

      return lists;
    }

    return false;
  }

  function buildReadMoreBlock(collection) {
    var list = $('<ul/>');

    collection.forEach(function(element) {
      $(list).append($('<li/>').text(element['list_title']));
    })
    
    return $('<div/>').append(list);
  }

  function buildInterface(collections, container) {
    collections = shrinkList(collections);

    collections.forEach(function(collection) {
      var block = buildReadMoreBlock(collection);
      $(container).append(block);
    });
  }

  exports.initialize = function(seedCategories, seedPermalink, container) {
    categories = seedCategories;
    permalink = seedPermalink;

    var remainingCategories = categories.length;
    var categoryCollections = [];

    categories.forEach(function(category) {
      var url = '/data-includes/categories/' + category + '.json';

      $.getJSON(url, function(data) {
        if (collection = buildCategoryCollection(data))
          categoryCollections.push(collection);

        remainingCategories -= 1;
        if (remainingCategories <= 0)
          buildInterface(categoryCollections, container);
      });
    });
  }
})(this.readMoreBlocks = {});