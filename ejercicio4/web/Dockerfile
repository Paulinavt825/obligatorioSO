# Use an official Node.js runtime as a parent image
FROM node:25-alpine

# Set the working directory in the container
WORKDIR /app

# Copy package.json and package-lock.json (if available)
COPY package*.json ./

# Install app dependencies
RUN npm install

# Copy the rest of the application source code
# web/ (maquina host) -> app/ (contenedor)
COPY . .

# Make port 5000 available to the world outside this container
EXPOSE 5000

# Define the command to run the app
CMD ["npm", "start"]
