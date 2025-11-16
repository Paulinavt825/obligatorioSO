# Usa una imagen oficial de Node.js como imagen base
FROM node:25.2-alpine

# Establece el directorio de trabajo en el contenedor
WORKDIR /app

# Copia el resto del código fuente de la aplicación
# src/ (máquina host) -> app/ (contenedor)
COPY src/ .

# Instala las dependencias de la aplicación
RUN npm install

# Hace que el puerto 5000 se muestre como disponible para exponer
EXPOSE 5000

# Define el comando para ejecutar la aplicación
CMD ["npm", "start"]
