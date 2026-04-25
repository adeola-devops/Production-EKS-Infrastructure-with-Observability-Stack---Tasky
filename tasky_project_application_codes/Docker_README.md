# Docker
A Dockerfile has been provided to run this application. The default port exposed is 8080.

## Running with Docker

1. Start a MongoDB container:
```bash
docker run -d --name mongo-test -p 27017:27017 mongo:latest
```

2. Build the application image:
```bash
docker build -t tasky:latest .
```

3. Run the application container:
```bash
docker run -d --name tasky --link mongo-test:mongo -p 8080:8080 -e MONGODB_URI="mongodb://mongo:27017" -e SECRET_KEY=your_secret_key tasky:latest
```

4. Access the application at http://localhost:8080

5. To clean up:
```bash
docker rm -f tasky mongo-test
docker rmi tasky:latest
```

# Environment Variables
The following environment variables are needed.
|Variable|Purpose|example|
|---|---|---|
|`MONGODB_URI`|Address to mongo server|`mongodb://servername:27017` or `mongodb://username:password@hostname:port` or `mongodb+srv://` schema|
|`SECRET_KEY`|Secret key for JWT tokens|`secret123`|

Alternatively, you can create a `.env` file and load it up with the environment variables.

# Running with Go

Clone the repository into a directory of your choice Run the command `go mod tidy` to download the necessary packages.

You'll need to add a .env file and add a MongoDB connection string with the name `MONGODB_URI` to access your collection for task and user storage.
You'll also need to add `SECRET_KEY` to the .env file for JWT Authentication.

Run the command `go run main.go` and the project should run on `locahost:8080`

# License

This project is licensed under the terms of the MIT license.

Original project: https://github.com/dogukanozdemir/golang-todo-mongodb