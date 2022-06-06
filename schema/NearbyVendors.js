cube(`NearbyOrders`, {
  extends: Orders,

  joins: {
    Vendors: {
      sql: `substring(${CUBE}.h3_9, 1, 4) = substring(${Vendors}.h3_9, 1, 4)`,
      relationship: `belongsTo`
    }
  },

  preAggregations: {
    nearbyOrdersByVendor: {
      measures: [NearbyOrders.count],
      dimensions: [Vendors.name]
    }
  },

  dataSource: `default`,
});
