#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

typedef struct bmpFileHeader
{
  /* 2 bytes de identificaci�n */
  uint32_t size;        /* Tama�o del archivo */
  uint16_t resv1;       /* Reservado */
  uint16_t resv2;       /* Reservado */
  uint32_t offset;      /* Offset hasta hasta los datos de imagen */
} bmpFileHeader;

typedef struct bmpInfoHeader
{
  uint32_t headersize;      /* Tama�o de la cabecera */
  uint32_t width;               /* Ancho */
  uint32_t height;          /* Alto */
  uint16_t planes;                  /* Planos de color (Siempre 1) */
  uint16_t bpp;             /* bits por pixel */
  uint32_t compress;        /* compresi�n */
  uint32_t imgsize;     /* tama�o de los datos de imagen */
  uint32_t bpmx;                /* Resoluci�n X en bits por metro */
  uint32_t bpmy;                /* Resoluci�n Y en bits por metro */
  uint32_t colors;              /* colors used en la paleta */
  uint32_t imxtcolors;      /* Colores importantes. 0 si son todos */
} bmpInfoHeader;

unsigned char *LoadBMP(char *filename, bmpInfoHeader *bInfoHeader);
void DisplayInfo(bmpInfoHeader *info);
