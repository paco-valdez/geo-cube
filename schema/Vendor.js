cube(`Vendors`, {
  sql: `SELECT * FROM vendors`,

  joins: {
  },

  measures: {
    count: {
      type: `count`
    }
  },

  dimensions: {
    id: {
      sql: `vendor_id`,
      type: `number`,
      primaryKey: true
    },
    name: {
      sql: `name`,
      type: `string`
    },
    location: {
      type: `geo`,
      latitude: {
        sql: `${CUBE}.lat`,
      },
      longitude: {
        sql: `${CUBE}.lon`,
      },
    },
    h3_9: {
      sql: `h3_9`,
      type: `string`
    },
  },

  dataSource: `default`
});