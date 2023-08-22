-- CreateTable
CREATE TABLE "backends" (
    "id" STRING NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "name" STRING NOT NULL,
    "client_id" STRING NOT NULL,
    "url" STRING NOT NULL,
    "default" BOOL NOT NULL DEFAULT false,

    CONSTRAINT "backends_pkey" PRIMARY KEY ("id")
);
