{-# LANGUAGE FlexibleInstances          #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}

module HaskellWorks.Data.Succinct.BalancedParens.Simple
  ( SimpleBalancedParens(..)
  , closeAt
  , findOpen
  , findClose
  , findClose'
  , openAt
  ) where

import           Control.Monad
import qualified Data.Vector.Storable                                       as DVS
import           Data.Word
import           HaskellWorks.Data.Bits.BitLength
import           HaskellWorks.Data.Bits.BitShow
import           HaskellWorks.Data.Bits.BitWise
import           HaskellWorks.Data.Positioning
import           HaskellWorks.Data.Succinct.BalancedParens.Internal
import           HaskellWorks.Data.Succinct.RankSelect.Binary.Basic.Rank0
import           HaskellWorks.Data.Succinct.RankSelect.Binary.Basic.Rank1
import           HaskellWorks.Data.Succinct.RankSelect.Binary.Basic.Select0
import           HaskellWorks.Data.Succinct.RankSelect.Binary.Basic.Select1
import           Prelude                                                    as P

newtype SimpleBalancedParens a = SimpleBalancedParens a
  deriving (BitLength, Eq, BitShow, TestBit, Rank0, Rank1, Select0, Select1)

instance Functor SimpleBalancedParens where
  fmap f (SimpleBalancedParens a) = SimpleBalancedParens (f a)
  {-# INLINABLE fmap   #-}

instance BitShow a => Show (SimpleBalancedParens a) where
  show = bitShow

closeAt :: TestBit a => a -> Count -> Bool
closeAt v c = not (v .?. toPosition (c - 1))
{-# INLINABLE closeAt #-}

openAt :: TestBit a => a -> Count -> Bool
openAt v c = v .?. toPosition (c - 1)
{-# INLINABLE openAt #-}

findOpen' :: (BitLength a, TestBit a) => Count -> SimpleBalancedParens a -> Count -> Maybe Count
findOpen' c v p = if 0 < p && p <= bitLength v
  then if v `openAt` p
    then if c == 0
      then Just p
      else findOpen' (c - 1) v (p - 1)
    else findOpen' (c + 1) v (p - 1)
  else Nothing
{-# INLINABLE findOpen' #-}

findClose' :: (BitLength a, TestBit a) => Count -> SimpleBalancedParens a -> Count -> Maybe Count
findClose' c v p = if 1 < p && p <= bitLength v
  then if v `closeAt` p
    then if c == 0
      then Just p
      else findClose' (c + 1) v (p + 1)
    else findClose' (c - 1) v (p + 1)
  else Nothing
{-# INLINABLE findClose' #-}

instance BalancedParens (SimpleBalancedParens [Bool]) where
  findOpen    v p = if v `openAt`  p then Just p else findOpen'  (Count 0) v (p - 1)
  findClose   v p = if v `closeAt` p then Just p else findClose' (Count 0) v (p + 1)
  enclose         = findOpen' (Count 1)
  firstChild  v p = if openAt v p && openAt v (p + 1)   then Just (p + 1) else Nothing
  nextSibling v p = findClose v p >>= (\q -> if (p /= q) then return (q + 1) else Nothing)
  parent      v p = enclose   v p >>= (\r -> if (r >= 1) then return r       else Nothing)
  {-# INLINABLE findOpen    #-}
  {-# INLINABLE findClose   #-}
  {-# INLINABLE enclose     #-}
  {-# INLINABLE firstChild  #-}
  {-# INLINABLE nextSibling #-}
  {-# INLINABLE parent      #-}

instance BalancedParens (SimpleBalancedParens (DVS.Vector Word8)) where
  findOpen    v p = if v `openAt`  p then Just p else findOpen'  (Count 0) v (p - 1)
  findClose   v p = if v `closeAt` p then Just p else findClose' (Count 0) v (p + 1)
  enclose         = findOpen' (Count 1)
  firstChild  v p = if openAt v p && openAt v (p + 1)   then Just (p + 1) else Nothing
  nextSibling v p = findClose v p >>= (\q -> if (p /= q) then return (q + 1) else Nothing)
  parent      v p = enclose   v p >>= (\r -> if (r >= 1) then return r       else Nothing)
  {-# INLINABLE findOpen    #-}
  {-# INLINABLE findClose   #-}
  {-# INLINABLE enclose     #-}
  {-# INLINABLE firstChild  #-}
  {-# INLINABLE nextSibling #-}
  {-# INLINABLE parent      #-}

instance BalancedParens (SimpleBalancedParens (DVS.Vector Word16)) where
  findOpen  v p = if v `openAt`  p then Just p else findOpen'  (Count 0) v (p - 1)
  findClose v p = if v `closeAt` p then Just p else findClose' (Count 0) v (p + 1)
  enclose       = findOpen' (Count 1)
  firstChild  v p = if openAt v p && openAt v (p + 1)   then Just (p + 1) else Nothing
  nextSibling v p = findClose v p >>= (\q -> if (p /= q) then return (q + 1) else Nothing)
  parent      v p = enclose   v p >>= (\r -> if (r >= 1) then return r       else Nothing)
  {-# INLINABLE findOpen    #-}
  {-# INLINABLE findClose   #-}
  {-# INLINABLE enclose     #-}
  {-# INLINABLE firstChild  #-}
  {-# INLINABLE nextSibling #-}
  {-# INLINABLE parent      #-}

instance BalancedParens (SimpleBalancedParens (DVS.Vector Word32)) where
  findOpen  v p = if v `openAt`  p then Just p else findOpen'  (Count 0) v (p - 1)
  findClose v p = if v `closeAt` p then Just p else findClose' (Count 0) v (p + 1)
  enclose       = findOpen' (Count 1)
  firstChild  v p = if openAt v p && openAt v (p + 1)   then Just (p + 1) else Nothing
  nextSibling v p = findClose v p >>= (\q -> if (p /= q) then return (q + 1) else Nothing)
  parent      v p = enclose   v p >>= (\r -> if (r >= 1) then return r       else Nothing)
  {-# INLINABLE findOpen    #-}
  {-# INLINABLE findClose   #-}
  {-# INLINABLE enclose     #-}
  {-# INLINABLE firstChild  #-}
  {-# INLINABLE nextSibling #-}
  {-# INLINABLE parent      #-}

instance BalancedParens (SimpleBalancedParens (DVS.Vector Word64)) where
  findOpen    v p = if v `openAt`  p then Just p else findOpen'  (Count 0) v (p - 1)
  findClose   v p = if v `closeAt` p then Just p else findClose' (Count 0) v (p + 1)
  enclose         = findOpen' (Count 1)
  firstChild  v p = if openAt v p && openAt v (p + 1)   then Just (p + 1) else Nothing
  nextSibling v p = findClose v p >>= (\q -> if (p /= q) then return (q + 1) else Nothing)
  parent      v p = enclose   v p >>= (\r -> if (r >= 1) then return r       else Nothing)
  {-# INLINABLE findOpen    #-}
  {-# INLINABLE findClose   #-}
  {-# INLINABLE enclose     #-}
  {-# INLINABLE firstChild  #-}
  {-# INLINABLE nextSibling #-}
  {-# INLINABLE parent      #-}

instance BalancedParens (SimpleBalancedParens Word8) where
  findOpen    v p = if v `openAt`  p then Just p else findOpen'  (Count 0) v (p - 1)
  findClose   v p = if v `closeAt` p then Just p else findClose' (Count 0) v (p + 1)
  enclose         = findOpen' (Count 1)
  firstChild  v p = if openAt v p && openAt v (p + 1)   then Just (p + 1) else Nothing
  nextSibling v p = findClose v p >>= (\q -> if (p /= q) then return (q + 1) else Nothing)
  parent      v p = enclose   v p >>= (\r -> if (r >= 1) then return r       else Nothing)
  {-# INLINABLE findOpen    #-}
  {-# INLINABLE findClose   #-}
  {-# INLINABLE enclose     #-}
  {-# INLINABLE firstChild  #-}
  {-# INLINABLE nextSibling #-}
  {-# INLINABLE parent      #-}

instance BalancedParens (SimpleBalancedParens Word16) where
  findOpen    v p = if v `openAt`  p then Just p else findOpen'  (Count 0) v (p - 1)
  findClose   v p = if v `closeAt` p then Just p else findClose' (Count 0) v (p + 1)
  enclose         = findOpen' (Count 1)
  firstChild  v p = if openAt v p && openAt v (p + 1)   then Just (p + 1) else Nothing
  nextSibling v p = findClose v p >>= (\q -> if (p /= q) then return (q + 1) else Nothing)
  parent      v p = enclose   v p >>= (\r -> if (r >= 1) then return r       else Nothing)
  {-# INLINABLE findOpen    #-}
  {-# INLINABLE findClose   #-}
  {-# INLINABLE enclose     #-}
  {-# INLINABLE firstChild  #-}
  {-# INLINABLE nextSibling #-}
  {-# INLINABLE parent      #-}

instance BalancedParens (SimpleBalancedParens Word32) where
  findOpen    v p = if v `openAt`  p then Just p else findOpen'  (Count 0) v (p - 1)
  findClose   v p = if v `closeAt` p then Just p else findClose' (Count 0) v (p + 1)
  enclose         = findOpen' (Count 1)
  firstChild  v p = if openAt v p && openAt v (p + 1)   then Just (p + 1) else Nothing
  nextSibling v p = findClose v p >>= (\q -> if (p /= q) then return (q + 1) else Nothing)
  parent      v p = enclose   v p >>= (\r -> if (r >= 1) then return r       else Nothing)
  {-# INLINABLE findOpen    #-}
  {-# INLINABLE findClose   #-}
  {-# INLINABLE enclose     #-}
  {-# INLINABLE firstChild  #-}
  {-# INLINABLE nextSibling #-}
  {-# INLINABLE parent      #-}

instance BalancedParens (SimpleBalancedParens Word64) where
  findOpen    v p = if v `openAt`  p then Just p else findOpen'  (Count 0) v (p - 1)
  findClose   v p = if v `closeAt` p then Just p else findClose' (Count 0) v (p + 1)
  enclose         = findOpen' (Count 1)
  firstChild  v p = if openAt v p && openAt v (p + 1)   then Just (p + 1) else Nothing
  nextSibling v p = findClose v p >>= (\q -> if (p /= q) then return (q + 1) else Nothing)
  parent      v p = enclose   v p >>= (\r -> if (r >= 1) then return r       else Nothing)
  {-# INLINABLE findOpen    #-}
  {-# INLINABLE findClose   #-}
  {-# INLINABLE enclose     #-}
  {-# INLINABLE firstChild  #-}
  {-# INLINABLE nextSibling #-}
  {-# INLINABLE parent      #-}
