# Shoe Store - CODE CHALLENGE
## Goal

**Design an interface that would allow the inventory department to monitor Aldo's stores and shoes inventory.**

Hope you’ll have fun with this little test. I know I had designing it.
Go wild. It can be anything you want. I’ve seen results printed to console, displayed on a webpage, and even someone who did periodical database dumps.

Here are a few ideas if you need an extra challenge:

- Add some sort of alerting system, e.g. When a shoe model at a store goes too low, or too high.
- Add a REST JSON API, or GraphQL
- Suggest shoe transfers from one store to another according to inventory
- Your own crazy idea!

Share your repository with us when you’re done.

Happy Hacking :)


# Solution
## Description
This is a Dockerized service, and the main goal is to keep listening to the Shoe Store sales; it is performed by a created Daemon, and this Daemon connects to the Shoe Store WebSocket that when receives a new deal the Daemon service should enqueue it to the RabbitMQ broker in an async way.
The enqueued job, when performed, should persist the message as JSONB data in the PostgresSQL database.

## Implemented Goals

### Alert System
A Scheduler was created to perform a Rake task named `whenever:handle_quantity_alerts_task`. This Rake task will perform some pre-defined Business Rules that are based on the Shoes Inventory:
* Business Rules:
    * **Quantity Alerts**: I don't have access to or know the rules applied to the Sales service, and we keep receiving nonstop sales even after receiving a sale with 0 as the left Quantity and right after receiving a sale for the same model.
      I suppose that we should have an estimation of the real Shoes Store Inventory, so we are summing the debts of shoes quantity and Publishing alerts due to the following pre-defined values:
        * *HIGH QUANTITY*: **-2999 to 0**
        * *LOW QUANTITY*: **-4800 to -3000**
        * *OUT OF STOCK*: **-6000 to -4801**

* When the estimated inventory quantity is any of those described above, an Alert will be Published to the RabbitMQ broker `:quantity_alerts` queue in an async way, and it will keep on the queue until it is consumed by any other **Consumer** that is subscribed to the `:quantity_alerts` queue.
    * Published messages follow a priority queue strategy, so the messages with the highest priority will be consumed first.
    * The priority queue strategy is based on the following rules:
        * *HIGH QUANTITY*: **9**
        * *LOW QUANTITY*: **10**
        * *OUT OF STOCK*: **11**
* A `QuantityAlertsConsumer` consumer was created as an example of how to consume the `:quantity_alerts` queue, this consumer will just print the received message to the console.

### JSON API Endpoint
A **JSON API** endpoint was created to expose the Shoes Store Inventory, this endpoint is available at the `/inventories` path, and it is possible to paginate the results by the following params:
* `page`: The page number to be returned ::Integer
* `per_page`: The number of records per page ::Integer
* `order`: The order of the records, it can be `ASC` or `DESC` ::String

* http://localhost:3000/inventories?page=1&per_page=2&order=DESC

Example of the JSON API returned result:
```json
{
  "data": [
    {
      "id": "13048",
      "type": "inventories",
      "attributes" : {
        "sales_data": {
          "id": "7b16de74-22dd-44f4-9c57-21b49cecba33",
          "model": "VENDOGNUS",
          "store": "ALDO Pheasant Lane Mall",
          "inventory":56
        },
      "created_at":"2023-01-06T04:51:02.462Z",
      "updated_at":"2023-01-06T04:51:02.462Z"
      }
    },
    {
      "id": "13047",
      "type": "inventories", 
      "attributes" : {
        "sales_data": {
          "id":"81a08fd3-3b97-4525-b6bb-e7fd221e3150", 
          "model": "ADERI",
          "store": "ALDO Burlington Mall", 
          "inventory":77
        },
        "created_at":"2023-01-06T04:51:02.461Z",
        "updated_at":"2023-01-06T04:51:02.461Z"
      }
    }
  ],
  "meta" : {
    "page" :1,
    "per_page":2,
    "order": "DESC",
    "total":12983
  }
}
```


### Suggest shoe transfers from one store to another according to inventory
A JSON API endpoint was created to expose the Shoes Transfer Suggestions, this endpoint is available at the `/shoes/transfer_suggestions` path, and it is possible to paginate the results by the following params:
  * `page`: The page number to be returned ::Integer
  * `per_page`: The number of records per page ::Integer
  * `order`: The order of the records, it can be `ASC` or `DESC` ::String

  * http://localhost:3000/inventories/transfer_suggestions?page=1&per_page=1&oder=ASC

Example of the JSON API returned result:
```json
{
  "data" :[
    {
      "id": "ALDO Auburn Mall",
      "type": "inventory_transfer_suggestions",
      "attributes" :{
        "from_store": "ALDO Auburn Mall",
        "shoes_model":"ABOEN",
        "inventory_quantity":-1940,
        "to_store":[
          {
            "store": "ALDO Waterloo Premium Outlets",
            "shoes_model":"ABOEN",
            "inventory_quantity":-4035
          },
          {
            "store": "ALDO Crossgates Mall",
            "shoes_model":"ABOEN",
            "inventory_quantity":-3607
          },
          {
            "store": "ALDO Solomon Pond Mall",
            "shoes_model":"ABOEN",
            "inventory_quantity":-3428
          },
          {
            "store": "ALDO Holyoke Mall",
            "shoes_model":"ABOEN",
            "inventory_quantity":-3187
          },
          {
            "store": "ALDO Pheasant Lane Mall",
            "shoes_model":"ABOEN",
            "inventory_quantity":-3184
          },
          {
            "store": "ALDO Centre Eaton",
            "shoes_model":"ABOEN",
            "inventory_quantity":-3142
          },
          {
            "store": "ALDO Burlington Mall",
            "shoes_model":"ABOEN",
            "inventory_quantity":-3127
          }
        ]
      }
    }
  ],
  "meta" :{
    "page": "1",
    "per_page": "1",
    "order": "DESC",
    "total":61
  }
}
```

***

## Extra Implemented Goals

### Dockerized Application
The application was dockerized and split into some containers:
* **Shoe Store API**: This container is responsible for running the Rails application.
* **Websocket Server**: This container runs the WebSocket server.
* **Shoe Sales Servless Handler**: This container is responsible for running a Daemon that executes a unique method responsible for consuming the WebSocket Server messages and processing them.
* **Postgres**: This container is responsible for running the PostgresSQL database.
* **RabbitMQ**: This container runs the RabbitMQ message broker.
* **Sneakers**: This container runs the sneakers workers.

Containers consume a `.env` file containing the environment variables used by the application. The `.env` file is located at the root of the project.

It has an entrypoint script file responsible for checking if the GEMS dependencies are installed. If not, it will install them, execute a shell script responsible for waiting during a pre-defined timeout for other containers to be ready, and start the application.

### Ruby 3 RBS
The application was implemented using the Ruby 3 RBS, it is a type system for Ruby, it is a static type checker for Ruby, it is a tool that helps you to write
more robust Ruby code.

### RabbitMQ
The application uses RabbitMQ as a message broker; it is a message broker that implements the Advanced Message Queuing Protocol (AMQP).

### Sneakers
The application uses Sneakers as a workers manager; it is a Ruby library that makes it easy to create background workers that process messages from RabbitMQ.

### Websocket Server
The application uses a websocket server to receive the shoe sales data; it is a websocket server implemented using the `faye-websocket` gem.

### Serverless Handler
The application uses a serverless handler to consume the WebSocket server messages and process them; it is a serverless handler that is implemented using the
`sneakers` gem.

### Logging
The application uses the default Ruby logger, a logger implemented using the `logger` gem and configured to log to the STDOUT.
Whenever GEM is configured to log to `logs/crontab.log` file and `logs/crontab_error.log` file.

***

## Code patterns and conventions used
- PORO (Plain Old Ruby Objects)
- DRY (Don't Repeat Yourself) as much as possible.
- Validate incoming external data using the `dry-validation` and `dry-monads` gems.
- SOLID principles.
- Encapsulation Principle was used to encapsulate the data and the methods of the classes.
- Entities were used to represent the data models.
- Repositories were used to abstract the data access layer.
- Controllers were used to exposing the JSON API endpoints.
- Business logic was extracted to a Business/Service Layer when needed.
- Well-named modules, class methods, and variables were used to make the code more readable.
- Log actions with messages were used to help to debug the application.
- JSONAPI specification was used to expose the JSON API endpoints because it is a well-known specification that avoids creating a custom JSON specification.
- JSONAPI-RB serializers were used to serialize the data models to JSON API format; this GEM is a well-known gem that implements the JSONAPI specification.
- Ruby 3 RBS was used to help to write more robust Ruby static-typed code.
- Pagination of ActiveRecord models and Arrays was used to paginate the JSON API endpoints.
- RAW SQL was used to improve the performance of the queries and avoid the N+1 problem when loading JSON API resource relationships.


## Application Architecture
- The application was implemented using **Sinatra** framework because it is a lightweight framework that is easy to set up and it is easy to implement.
- **PostgresSQL** was used because it offers features from SQL and NoSQL databases. I am persisting JSON data into JSONB columns since the expected incoming data
  is JSON data that does not need any internal relationship with other entities.
- **Docker** was used to containerize the application because it makes it easy to set up the application in any environment and deploys it quickly, for example, in **Kubernetes**.
- **Active** family GEMS were used because they are easy to use and are well documented and tested.
- **Sandbox**, there is an environment variable in **.ENV** file that can be used to enable the sandbox mode; when the sandbox mode is **TRUE**, the application
  will not persist the sales data into the database, it will only log the data to the STDOUT.
- **RabbitMQ** was used as a message broker because it is a free and open-source message-broker software that implements the **Advanced Message Queuing Protocol**
  provides features such as **Sidekiq PRO** but for free, and it is well known as a fail-over message broker since it is built on top of **Erlang** ecosystem.
- **Sneakers** was used as a workers manager because it is a Ruby library that makes it easy to create **background workers** and **Pub/Sub** workers that process messages
  from RabbitMQ.
- A **serverless handler** was implemented to consume the WebSocket server messages and process them; it is a serverless handler that acts as a **daemon** that
  executes a unique method that is responsible for consuming the WebSocket Server messages and processes them in the future should be easy to change this
  service to a serverless container like **AWS Lambda** or **Google Cloud Functions**.

***

## RabbitMQ Management
**URL:** `http://localhost:15672`

**Username:** `guest` / **Password:** `guest`


## Starting the project
- Open a terminal and create a brand new `.env` file:
```shell
  cp -a .env.development .env
```
- At the same tab, run:
```shell
docker-compose up --build
```

- Now let's create the network running:
```shell
  docker network create dev_ntw
```

- Time to create the database and execute the migrations:
```shell
docker-compose run shoe_store_api rake db:create --trace && docker-compose run shoe_store_api rake db:migrate --trace
```
- After that, let's start the whole project:
```shell
  docker-compose up
```

## SANDBOX mode
- With the project not running, open the `.env` file and change the `SANDBOX` variable to `true`:
```shell
  SANDBOX=true
```
- Open a terminal and on the root of the project run:
```shell
docker-compose up
```

## Running the RSpec tests
- In a terminal tab, run the rspec tests:
```shell
  docker-compose run -e APP_ENV=test shoe_store_api rspec --format documentation
```

## Code Coverage
<img width="1792" alt="Screenshot 2023-01-19 at 03 25 37" src="https://user-images.githubusercontent.com/71681750/213371507-8f4711ca-142b-4195-a960-fc20e541b387.png">


## Tech Stack
- Docker
- Docker Compose
- Ruby 3.1.3
- RBS
- Sinatra
- PostgreSQL 13.9
- RabbitMQ
- Whenever for scheduling tasks
- Sneakers for processing jobs and PUB/SUB through RabbitMQ broker
- Websocket
- Daemons
- RSpec


## Improvements
- Implement a **Redis** cache to cache the JSON API endpoints.
- Gather more info about inventory and improve the Inventory Alert rules and email the store owner when the inventory is low.
- Implement filters to the JSON API endpoints.
- Explain queries and add indexes to improve the performance of the queries if needed.

