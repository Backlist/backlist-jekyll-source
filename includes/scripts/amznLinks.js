(function(exports) {
  var defaultDomain = "amazon.com";
  var defaultAffiliate;
  var countries = ["CA", "DE", "ES", "FR", "GB", "IT"];
  var domains = {
    "CA": "amazon.ca",
    "DE": "amazon.de",
    "ES": "amazon.es",
    "FR": "amazon.fr",
    "GB": "amazon.co.uk",
    "IT": "amazon.it"
  };
  var affiliates;

  exports.localizeLinks = function(selector, countryCode) {
    if (countries.indexOf(countryCode)) {
      $(selector).each(function() {
        var reUrl = /amazon.com/i;
        var reAffiliate = /backlist0e-20/i;
        var href = $(this).attr('href');

        href = href.replace(reUrl, domains[countryCode]);
        href = href.replace(reAffiliate, affiliates[countryCode]);
        $(this).attr('href', href);
      });
    }
  };

  exports.initialize = function(
                          seedDefaultAffiliate, seedAffiliates, 
                          seedCountries, seedDomains, seedDefaultDomain) {
    if (seedDefaultDomain)
      defaultDomain = seedDefaultDomain;
    if (seedCountries)
      countries = seedCountries;
    if (seedDomains)
      domains = seedDomains;

    defaultAffiliate = seedDefaultAffiliate;
    affiliates = seedAffiliates;
  }
})(this.amznLinks = {});