{-# OPTIONS_GHC-funbox-strict-fields #-}

{-# LANGUAGE BangPatterns        #-}
{-# LANGUAGE DeriveAnyClass      #-}
{-# LANGUAGE DeriveGeneric       #-}
{-# LANGUAGE FlexibleContexts    #-}
{-# LANGUAGE FlexibleInstances   #-}
{-# LANGUAGE MultiWayIf          #-}
{-# LANGUAGE Rank2Types          #-}
{-# LANGUAGE ScopedTypeVariables #-}

module HaskellWorks.Data.RankSelect.CsPoppy
    ( CsPoppy(..)
    , makeCsPoppy
    ) where

import Control.DeepSeq
import Data.Word
import GHC.Generics
import HaskellWorks.Data.BalancedParens.BalancedParens
import HaskellWorks.Data.BalancedParens.CloseAt
import HaskellWorks.Data.BalancedParens.Enclose
import HaskellWorks.Data.BalancedParens.FindClose
import HaskellWorks.Data.BalancedParens.FindCloseN
import HaskellWorks.Data.BalancedParens.FindOpen
import HaskellWorks.Data.BalancedParens.FindOpenN
import HaskellWorks.Data.BalancedParens.NewCloseAt
import HaskellWorks.Data.BalancedParens.OpenAt
import HaskellWorks.Data.Bits.BitLength
import HaskellWorks.Data.Bits.BitRead
import HaskellWorks.Data.Bits.BitWise
import HaskellWorks.Data.Bits.PopCount.PopCount0
import HaskellWorks.Data.Bits.PopCount.PopCount1
import HaskellWorks.Data.FromForeignRegion
import HaskellWorks.Data.RankSelect.Base.Rank0
import HaskellWorks.Data.RankSelect.Base.Rank1
import HaskellWorks.Data.RankSelect.Base.Select0
import HaskellWorks.Data.RankSelect.Base.Select1
import HaskellWorks.Data.RankSelect.CsPoppy.Internal.CsInterleaved
import HaskellWorks.Data.RankSelect.CsPoppy.Internal.Vector
import HaskellWorks.Data.Vector.AsVector64
import Prelude                                                     hiding (drop, length, pi, take)

import qualified Data.Vector.Storable                                 as DVS
import qualified HaskellWorks.Data.RankSelect.CsPoppy.Internal.Alpha0 as A0
import qualified HaskellWorks.Data.RankSelect.CsPoppy.Internal.Alpha1 as A1

data CsPoppy = CsPoppy
  { csPoppyBits   :: !(DVS.Vector Word64)
  , csPoppyIndex0 :: !A0.CsPoppyIndex
  , csPoppyIndex1 :: !A1.CsPoppyIndex
  } deriving (Eq, Show, NFData, Generic)

instance FromForeignRegion CsPoppy where
  fromForeignRegion = makeCsPoppy . fromForeignRegion

instance AsVector64 CsPoppy where
  asVector64 = asVector64 . csPoppyBits
  {-# INLINE asVector64 #-}

instance BitLength CsPoppy where
  bitLength = bitLength . csPoppyBits
  {-# INLINE bitLength #-}

instance PopCount0 CsPoppy where
  popCount0 v = getCsiTotal (CsInterleaved (lastOrZero (A0.csPoppyLayerM (csPoppyIndex0 v))))
  {-# INLINE popCount0 #-}

instance PopCount1 CsPoppy where
  popCount1 v = getCsiTotal (CsInterleaved (lastOrZero (A1.csPoppyLayerM (csPoppyIndex1 v))))
  {-# INLINE popCount1 #-}

makeCsPoppy :: DVS.Vector Word64 -> CsPoppy
makeCsPoppy v = CsPoppy
  { csPoppyBits   = v
  , csPoppyIndex0 = A0.makeCsPoppyIndex v
  , csPoppyIndex1 = A1.makeCsPoppyIndex v
  }

instance TestBit CsPoppy where
  (.?.) = (.?.) . csPoppyBits
  {-# INLINE (.?.) #-}

instance BitRead CsPoppy where
  bitRead = fmap makeCsPoppy . bitRead

instance Rank0 CsPoppy where
  rank0 (CsPoppy !v i _) = A0.rank0On v i
  {-# INLINE rank0 #-}

instance Rank1 CsPoppy where
  rank1 (CsPoppy !v _ i) = A1.rank1On v i
  {-# INLINE rank1 #-}

instance Select0 CsPoppy where
  select0 (CsPoppy !v i _) = A0.select0On v i
  {-# INLINE select0 #-}

instance Select1 CsPoppy where
  select1 (CsPoppy !v _ i) = A1.select1On v i
  {-# INLINE select1 #-}

instance OpenAt CsPoppy where
  openAt = openAt . csPoppyBits
  {-# INLINE openAt #-}

instance CloseAt CsPoppy where
  closeAt = closeAt . csPoppyBits
  {-# INLINE closeAt #-}

instance NewCloseAt CsPoppy where
  newCloseAt = newCloseAt . csPoppyBits
  {-# INLINE newCloseAt #-}

instance FindOpenN CsPoppy where
  findOpenN = findOpenN . csPoppyBits
  {-# INLINE findOpenN #-}

instance FindOpen CsPoppy where
  findOpen = findOpen . csPoppyBits
  {-# INLINE findOpen #-}

instance FindClose CsPoppy where
  findClose = findClose . csPoppyBits
  {-# INLINE findClose #-}

instance FindCloseN CsPoppy where
  findCloseN = findCloseN . csPoppyBits
  {-# INLINE findCloseN #-}

instance Enclose CsPoppy where
  enclose = enclose . csPoppyBits
  {-# INLINE enclose #-}

instance BalancedParens CsPoppy where
  firstChild  = firstChild  . csPoppyBits
  nextSibling = nextSibling . csPoppyBits
  parent      = parent      . csPoppyBits
  {-# INLINE firstChild  #-}
  {-# INLINE nextSibling #-}
  {-# INLINE parent      #-}
