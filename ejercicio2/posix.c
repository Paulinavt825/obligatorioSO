#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <semaphore.h>
#include <unistd.h> // for sleep
#include <time.h>

// gcc posix.c -o posix -lpthread
// ./posix

typedef struct {
    int oficinista_id;
    int count;
} OficinistaArgs;

typedef struct {
    int pasajero_id;
    int count;
} PasajerosArgs;

int read_cnt = 0;
sem_t wrt;
pthread_mutex_t mutex;

void modificarCartel(int oficinista_id) {
    sem_wait(&wrt);
    // %d -> toma proximo parametro, en este caso oficinista_id
    printf("\033[1;34mOficinista %d\033[0m está modificando el cartel\n", oficinista_id);
    sleep(rand() % 5 + 1);
    sem_post(&wrt);
}

void* oficinista(void* args) {
    sleep(rand() % 5);
    OficinistaArgs* o_args = (OficinistaArgs*)args;
    for (int i = 0; i < o_args->count; ++i) {
        modificarCartel(o_args->oficinista_id);
        usleep(rand() % 1500000); // 1.5 secs
    }
    free(args);
    return NULL;
}

void leerCartel(int pasajero_id) {
    pthread_mutex_lock(&mutex);
    read_cnt++;
    if (read_cnt == 1) sem_wait(&wrt);
    pthread_mutex_unlock(&mutex);

    printf("\033[1;32mPasajero %d\033[0m está mirando el cartel\n", pasajero_id);
    sleep(rand() % 3 + 1);

    pthread_mutex_lock(&mutex);
    read_cnt--;
    if(read_cnt == 0) sem_post(&wrt);
    pthread_mutex_unlock(&mutex);
}

void* pasajero(void* args){
    sleep(rand() % 80);
    PasajerosArgs* p_args = (PasajerosArgs*)args;
    for (int i = 0; i < p_args->count; ++i) {
        leerCartel(p_args->pasajero_id);
        usleep(rand() % 3000000); // 3 secs
    }
    free(args);
    return NULL;
}

int main() {
    srand(time(NULL)); // Inicializa rand() con la hora actual para generar tiempos aleatorios distintos
    sem_init(&wrt, 0, 1); // 2do arg, 0 para hilos del mismo proceso y 1 para distinto proceso
    pthread_mutex_init(&mutex, NULL);

    const int numOficinistas = rand() % 6 + 5; // min 5 max 10
    const int numPasajeros = rand() % 21 + 100; // min 100 max 120

    pthread_t oficinistas[numOficinistas];
    pthread_t pasajeros[numPasajeros];

    for (int i = 0; i < numOficinistas; ++i) {
        OficinistaArgs* args = (OficinistaArgs*)malloc(sizeof(OficinistaArgs));
        args->oficinista_id = i;
        args->count = rand() % 10 + 3; // min 3 max 12
        pthread_create(&oficinistas[i], NULL, oficinista, args);
    }

    for (int i = 0; i < numPasajeros; ++i) {
        PasajerosArgs* args = (PasajerosArgs*)malloc(sizeof(PasajerosArgs));
        args->pasajero_id = i;
        args->count = rand() % 5 + 1; // min 1 max 5
        pthread_create(&pasajeros[i], NULL, pasajero, args);
    }

    for (int i = 0; i < numOficinistas; ++i) {
        pthread_join(oficinistas[i], NULL);
    }

    for (int i = 0; i < numPasajeros; ++i) {
        pthread_join(pasajeros[i], NULL);
    }

    sem_destroy(&wrt);
    pthread_mutex_destroy(&mutex);

    return 0;
}