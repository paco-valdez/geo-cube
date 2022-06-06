# Cube.js Geo example

This is a self-contained Cube.js example with Geographic data.
In this example I'm using [H3](https://github.com/uber/h3) geographic hashing algorithm, 
although any other hashing algorithm can be used. (e.g. [Geohash](https://en.wikipedia.org/wiki/Geohash))
The objective is to showcase how Cube.js can perform pre-aggregations from joins using H3.

## Data setup

In the `structure.sql` file I'm creating a table for orders and vendors.
Then I'm adding coordinates and H3 hashes (resolution 9) to every order and vendor.
```sql
insert into vendors (tenant_id,vendor_id, name, credit_limit, lat, lon, h3_9) values
  (1, 1, 'Acme', 10230, 32.743249, -117.189582, '29a411a2b')
, (1, 2, 'National', 456.12, 32.671550, -117.114431, '29a41a58b')  -- this vendor will have no orders
, (1, 3, 'Empty', 101.01, 33.758991, -118.245725, '29a560687')
on conflict do nothing;

insert into orders (tenant_id, order_id, vendor_id, title, budgeted_amount, lat, lon, h3_9) values
  (1,1,1,'$100 order w/3li', 100.00, 32.78401236891236, -117.19916781641939, '29a4031db')
, (1,2,1,'$200 order w/1li', 200.00, 32.72343350245376, -117.1304643948471 , '29a41a8d3')
, (1,3,1,'$302 order w/0li', 302.00, 32.71695046609805, -117.16107380616378, '29a41ad8b')
, (1,4,3,'$404 order w/0li', 404.00, 33.82524899050014, -118.02409857821776, '29a56b28f')
on conflict do nothing;
```

Note: I'm storing only the significative characters of the H3 hash.
The H3 hash contains some extra characters at the beginning (`8` followed by the resolution level) 
and at the end (`f` padded until reaching the max character length). 
A typical H3 hash looks like: `83485bfffffffff`. 
By removing extra characters is possible to perform string operations like `contains`.


## Modeling

Then in the Orders and Vendors section we add the following dimension:
```javascript
dimensions: {
    ...
    h3_9: {
      sql: `h3_9`,
      type: `string`
    },
    ...
  },
```

Then we can define how we will join both cubes 
by creating a new cube that extends the existing Orders cube:
```javascript
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
```
First we define how we are going to join the cubes geographically.
We are "rolling up" the resolution of the hash from 9 to 4, 
to identify which orders are nearby to every Vendor. 
Imagine we would like to know all the possible opportunities for each vendor.
This method is several orders of magnitude faster than [ST_DWithin](https://postgis.net/docs/ST_DWithin.html).
Although, the downside is that we lose accuracy, since we rely on where the coordinates are positioned 
within each hash geometry.

![](static/hexbin4.png)


Once we have our schema defined we can verify in the playground that our geographical join is pre-aggregated.
I created 3 orders nearby `Acme` and `National` vendors. And 1 nearby to `Empty` vendor.

![](static/geo-preagg.png)

## Launch

Run docker-compose file
```sh
docker-compose up
```

