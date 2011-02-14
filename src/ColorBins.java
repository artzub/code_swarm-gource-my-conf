/**
 * Copyright 2008 Michael Ogawa
 *
 * This file is part of code_swarm.
 *
 * code_swarm is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * code_swarm is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with code_swarm.  If not, see <http://www.gnu.org/licenses/>.
 */

import processing.core.PApplet;

/**
 * @brief Definition of the colored histogram elements
 */
class ColorBins
{
  int [] colorList;
  int num;

  ColorBins()
  {
    colorList = new int[2];
    num = 0;
  }

  public void add( int c )
  {
    if ( num >= colorList.length )
      colorList = PApplet.expand( colorList );

    colorList[num] = c;
    num++;
  }

  public void sort()
  {
    colorList = PApplet.sort( colorList );
  }
}

