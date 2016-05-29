#include <stdio.h>
#include <string.h>
#include <conio.h>
#include "ecrypt-sync.h"
#include "bpm-file.h"

void iniciar_programa();
void abrir_imagen(bmpInfoHeader *, char **);
void elegir_opcion(int *);
void encriptar_imagen(char *, bmpInfoHeader);
void desencriptar_imagen(char *, bmpInfoHeader);

char *dir = "C:\\boca.bmp";

int main() {

	int opcion = 0;
	bmpInfoHeader header;
	char *body = NULL;

	iniciar_programa();
	abrir_imagen(&header, &body);
	elegir_opcion(&opcion);

	if(opcion == 1) {
		encriptar_imagen(body, header);
	} else if(opcion == 2) {
		desencriptar_imagen(body, header);
	}

	return 0;
}

void iniciar_programa() {
	printf("CriptoApp - Grain128a\n\n");
	printf("Elegir una opcion:\n");
	printf("1 - Encriptar archivo.bmp\n");
	printf("2 - Desencriptar archivo.bmp\n");
	return;
}

void abrir_imagen(bmpInfoHeader *header, char **body) {
	*body = LoadBMP(dir,header);
	return;
}

void elegir_opcion(int *opcion) {

	scanf("%u",opcion);
	printf("\n");

	while(*opcion != 1 && *opcion != 2) {
		printf("Elegir una opcion entre [1;2]\n");
		scanf("%u",opcion);
		printf("\n");
	}

	return;
}

void encriptar_imagen(char *plaintext, bmpInfoHeader header) {
	ECRYPT_ctx ctx;
	u8 key[16] = {0x01,0x23,0x45,0x67,0x89,0xab,0xcd,0xef,0x12,0x34,0x56,0x78,0x9a,0xbc,0xde,0xf0},
		IV[12] = {0x01,0x23,0x45,0x67,0x89,0xab,0xcd,0xef,0x12,0x34,0x56,0x78};
	u32 msglen = header.imgsize;
	char ciphertext[msglen];
	ECRYPT_init();
	ECRYPT_keysetup(&ctx,key,128,96);
	ECRYPT_ivsetup(&ctx,IV);
	ECRYPT_encrypt_bytes(&ctx,plaintext,ciphertext,msglen);
	SaveBMP(dir, ciphertext, msglen);
}

void desencriptar_imagen(char *ciphertext, bmpInfoHeader header) {
	ECRYPT_ctx ctx;
	u8 key[16] = {0x01,0x23,0x45,0x67,0x89,0xab,0xcd,0xef,0x12,0x34,0x56,0x78,0x9a,0xbc,0xde,0xf0},
		IV[12] = {0x01,0x23,0x45,0x67,0x89,0xab,0xcd,0xef,0x12,0x34,0x56,0x78};
	u32 msglen = header.imgsize;
	char plaintext[msglen];
	ECRYPT_init();
	ECRYPT_keysetup(&ctx,key,128,96);
	ECRYPT_ivsetup(&ctx,IV);
	ECRYPT_decrypt_bytes(&ctx,ciphertext,plaintext,msglen);
	SaveBMP(dir, plaintext, msglen);
	return;
}
