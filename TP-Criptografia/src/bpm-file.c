#include "bpm-file.h"

unsigned char *LoadBMP(char *filename, bmpInfoHeader *bInfoHeader) {

	FILE *f;
	bmpFileHeader header; /* cabecera */
	unsigned char *imgdata; /* datos de imagen */
	uint16_t type; /* 2 bytes identificativos */

	f = fopen(filename, "r");
	if (!f)
		return NULL; /* Si no podemos leer, no hay imagen*/

	/* Leemos los dos primeros bytes */
	fread(&type, sizeof(uint16_t), 1, f);
	if (type != 0x4D42) { /* Comprobamos el formato */
		fclose(f);
		return NULL;
	}

	/* Leemos la cabecera de fichero completa */
	fread(&header, sizeof(bmpFileHeader), 1, f);

	/* Leemos la cabecera de informaci�n completa */
	fread(bInfoHeader, sizeof(bmpInfoHeader), 1, f);

	/* Reservamos memoria para la imagen, �cu�nta?
	 Tanto como indique imgsize */
	imgdata = (unsigned char*) malloc(bInfoHeader->imgsize);

	/* Nos situamos en el sitio donde empiezan los datos de imagen,
	 nos lo indica el offset de la cabecera de fichero*/
	fseek(f, header.offset, SEEK_SET);

	/* Leemos los datos de imagen, tantos bytes como imgsize */
	fread(imgdata, bInfoHeader->imgsize, 1, f);

	/* Cerramos */
	fclose(f);

	/* Devolvemos la imagen */
	return imgdata;
}

unsigned char *SaveBMP(char *filename, char *data, uint32_t msglen) {
	FILE *f;
	bmpFileHeader header; /* cabecera */
	bmpInfoHeader bInfoHeader;
	uint16_t type; /* 2 bytes identificativos */

	f = fopen(filename, "r");
	if (!f)
		return NULL; /* Si no podemos leer, no hay imagen*/

	/* Leemos los dos primeros bytes */
	fread(&type, sizeof(uint16_t), 1, f);
	if (type != 0x4D42) { /* Comprobamos el formato */
		fclose(f);
		return NULL;
	}

	/* Leemos la cabecera de fichero completa */
	fread(&header, sizeof(bmpFileHeader), 1, f);

	/* Leemos la cabecera de informaci�n completa */
	fread(&bInfoHeader, sizeof(bmpInfoHeader), 1, f);


	FILE *f2;
	f2 = fopen("C:\\boca2.bmp", "w");
	if (!f)
		return NULL;

	/* Leemos los datos de imagen, tantos bytes como imgsize */
	fwrite(&type, sizeof(uint16_t), 1, f2);
	fwrite(&header, sizeof(bmpFileHeader), 1, f2);
	fwrite(&bInfoHeader, sizeof(bmpInfoHeader), 1, f2);
	fwrite(data, sizeof(char), msglen, f2);

	/* Nos situamos en el sitio donde empiezan los datos de imagen,
	 nos lo indica el offset de la cabecera de fichero*/
	//fseek(f, header.offset, SEEK_SET);

	/* Leemos los datos de imagen, tantos bytes como imgsize */
	//fwrite(data, sizeof(char), strlen(data), f);

	/* Cerramos */
	fclose(f);
	fclose(f2);

	/* Devolvemos la imagen */
	return 0;
}

void DisplayInfo(bmpInfoHeader *info) {
	printf("Tama�o de la cabecera: %u\n", info->headersize);
	printf("Anchura: %d\n", info->width);
	printf("Altura: %d\n", info->height);
	printf("Planos (1): %d\n", info->planes);
	printf("Bits por pixel: %d\n", info->bpp);
	printf("Compresi�n: %d\n", info->compress);
	printf("Tama�o de datos de imagen: %u\n", info->imgsize);
	printf("Resoluc�n horizontal: %u\n", info->bpmx);
	printf("Resoluc�n vertical: %u\n", info->bpmy);
	printf("Colores en paleta: %d\n", info->colors);
	printf("Colores importantes: %d\n", info->imxtcolors);
}
