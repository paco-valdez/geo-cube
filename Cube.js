const h3 = require("h3-js");

module.exports = {
  queryRewrite: (query, { securityContext }) => {
    console.log(`Query before modifying`);
    console.log(query)
    for (const filter of query.filters) {
      console.log(filter)
      if (filter.member === `Orders.location` && filter.operator === `equals`) {
        filter.member = `Orders.h3_5`;
        let newValues = [];
        for (const value of filter.values) {
          let coodinates = value.split(',').map(s => s.trim());
          // First two characters are ignored, then we ignore the rest after character 8 on res 5
          newValues.push(
            h3.geoToH3(Number(coodinates[0]), Number(coodinates[1]), 5)
              .substring(2, 8)
          );
        }

        filter.values =  newValues;
      }
    }
    console.log(`Query After Modifying`);
    console.log(query)
    return query;
  },
};