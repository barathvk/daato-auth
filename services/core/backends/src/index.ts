import {
  Body,
  Controller,
  Delete,
  Get,
  Module,
  Param,
  Post,
  Put,
} from '@nestjs/common'
import { ApiOkResponse, ApiOperation, OmitType } from '@nestjs/swagger'

import { ModelModule, ModelService, ent } from '@core/model'

export class BackendDto extends OmitType(ent.Backend, [
  'id',
  'createdAt',
  'updatedAt',
]) {}

@Controller('backends')
export class BackendsController {
  constructor(private readonly model: ModelService) {}
  @Get()
  @ApiOperation({ summary: 'List backends' })
  @ApiOkResponse({ type: [ent.Backend] })
  async list() {
    return this.model.backend.findMany()
  }

  @Post()
  @ApiOperation({ summary: 'Create backend' })
  @ApiOkResponse({ type: ent.Backend })
  async create(@Body() body: BackendDto) {
    return this.model.backend.create({ data: body })
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get backend' })
  @ApiOkResponse({ type: ent.Backend })
  async read(@Param('id') id: string) {
    return this.model.backend.findUniqueOrThrow({ where: { id } })
  }

  @Put(':id')
  @ApiOperation({ summary: 'Update backend' })
  @ApiOkResponse({ type: ent.Backend })
  async update(@Param('id') id: string, @Body() body: BackendDto) {
    return this.model.backend.update({ where: { id }, data: body })
  }

  @Delete(':id')
  @ApiOperation({ summary: 'Delete backend' })
  @ApiOkResponse({ type: ent.Backend })
  async delete(@Param('id') id: string) {
    return this.model.backend.delete({ where: { id } })
  }
}

@Module({
  imports: [ModelModule],
  controllers: [BackendsController],
})
export class BackendsModule {}
