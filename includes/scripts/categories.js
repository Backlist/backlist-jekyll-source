function CategoriesTable(prefix) {
  this.prefix = prefix;
  this.table = document.getElementById(prefix + '-categories-table');
  this.tabPanelPairs = [
    [document.getElementById(prefix + '-all-categories-tab'),
      document.getElementById(prefix + '-all-categories-panel')],
    [document.getElementById(prefix + '-chrono-categories-tab'),
      document.getElementById(prefix + '-chrono-categories-panel')],
    [document.getElementById(prefix + '-geo-categories-tab'),
      document.getElementById(prefix + '-geo-categories-panel')],
    [document.getElementById(prefix + '-theme-categories-tab'),
      document.getElementById(prefix + '-theme-categories-panel')]
  ];
  this.disclosureContainer = document.getElementById(prefix + '-categories-disclosure');

  this.setup = function() {
    var thisTable = this;

    $(thisTable.table).css('display', 'none');
    $(thisTable.disclosureContainer).children('a').on('click', function(e) {
      e.preventDefault();
      $(thisTable.disclosureContainer).hide();
      $(thisTable.table).fadeIn();
    });

    $(thisTable.tabPanelPairs).each(function() {
      var $tab = $(this[0]), $panel = $(this[1]);
      var containingTable = thisTable;

      $(this[0]).on('click', function(e) {
        e.preventDefault();
        $(containingTable.table)
          .children('.display-table')
          .children('.table-tab-bar')
          .children('ul').children('li')
          .children('a').removeClass('here');
        $(containingTable.table).children('.display-table').children('.table-panels').children('.table-panel').removeClass('here');

        $tab.addClass('here');
        $panel.addClass('here');
      });
    });
  };
}
