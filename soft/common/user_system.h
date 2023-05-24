/*
 * SPDX-FileCopyrightText: 2022 , Julien OURY
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * SPDX-License-Identifier: Apache-2.0
 * SPDX-FileContributor: Created by Julien OURY <julien.oury@outlook.fr>
 */

#ifndef USER_SYSTEM_H__
#define USER_SYSTEM_H__

#define addr_mprj_internal_ram ((volatile uint32_t*) 0x30000000)

#define reg_mprj_internal_ram  (*(volatile uint32_t*)0x30000000)
#define reg_mprj_sys_mng       (*(volatile uint32_t*)0x30001000)

#define SYS_MNG_START_CODE     ((uint32_t) 0x1A2B3C01)
#define SYS_MNG_STOP_CODE      ((uint32_t) 0x1A2B3C00)

#endif  // USER_SYSTEM_H__
